
#' @export
filterNewsPages <- function(webpage, journal = NULL){
  if(is.null(journal)) journal <- "folha"

  if(journal == "folha")
    return(webpage %>%
      rvest::html_elements("main") %>%
      rvest::html_elements("a") %>%
      rvest::html_attr("href") %>%
      .[gdata::startsWith(., "http")] %>%
      stringr::str_subset("search", negate = TRUE) %>%
      unique())

  if(journal == "estadao")
    return(webpage %>%
      rvest::html_elements("body") %>%
      rvest::html_elements("a") %>%
      rvest::html_attr("href") %>%
      .[gdata::startsWith(., "http")] %>%
      stringr::str_subset("wa.me", negate = TRUE) %>%
      stringr::str_subset("facebook.com", negate = TRUE) %>%
      stringr::str_subset("linkedin.com", negate = TRUE) %>%
      stringr::str_subset("twitter.com", negate = TRUE) %>%
      stringr::str_subset("instagram.com", negate = TRUE) %>%
      stringr::str_subset("pinterest.com", negate = TRUE) %>%
      stringr::str_subset("assine.estadao.com.br", negate = TRUE) %>%
      stringr::str_subset("noticias|blogs") %>%
      unique() %>%
      sort())
}

#' @export
filterNextResults <- function(webpage){
  links <- webpage %>%
    rvest::html_elements("main") %>%
    rvest::html_elements("a") %>%
    rvest::html_attr("href") %>%
    as.character() %>%
    stringr::str_subset("search") %>%
    unique()

  return(links)
}

#' @export
getQueryLink <- function(query, year, journal = NULL){
  if(is.null(journal)) journal <- "folha"

  if(journal == "folha")
    return(paste0("https://busca.folha.uol.com.br/search?q=",
                  query,
                  "&periodo=personalizado&sd=01%2F01%2F",
                  year,
                  "&ed=31%2F12%2F",
                  year,
                  "&site=todos"))
  if(journal == "estadao")
    return(paste0("https://busca.estadao.com.br/?tipo_conteudo=Todos&quando=01%2F01%2F",
                  year,
                  "-18%2F11%2F",
                  year,
                  "&q=",
                  query))

  if(journal == "valor")
    return(paste0("https://valor.globo.com/busca?q=",
                  query,
                  "&page=1&order=recent&from=",
                  year,
                  "-01-01T00%3A00%3A00-0300&to=",
                  year,
                  "-12-31T23%3A59%3A59-0300"))

  return(NULL)
}

#' @export
saveLinks <- function(links, directory){
  if(!dir.exists(directory))
    dir.create(directory)

  total <- length(links)
  message(paste0("Saving ", total, " links into directory '", directory, "'"))
  p <- progressr::progressor(total)
  for(link in links){
    p()
    saveLink(link, directory)
  }
}

#' @export
getContent <- function(link){
  webpage <- getWebpage(link)

  title <- webpage %>%
    rvest::html_elements("title") %>%
    rvest::html_text() %>%
    .[1] %>%
    as.character()

  text <- webpage %>%
    rvest::html_elements("p") %>%
    rvest::html_text() %>%
    as.character()

  return(c(title, text))
}

stringAsFileName <- function(mystring)
{
  mystring %>%
    stringr::str_replace_all("/", "_") %>%
    stringr::str_replace_all("\\?", "_") %>%
    stringr::str_replace_all("=", "_")
}

#' @export
saveLink <- function(link, directory){
  filename <- substr(link, 9, nchar(link)) %>%
    stringAsFileName() %>%
    paste0(".txt")

  outputFile <- paste0(directory, "/", filename)

  if(!file.exists(outputFile)){
    content <- getContent(link)
    write.table(content, outputFile, row.names = FALSE, col.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")
  }
}

#' @export
getWebpage <- function(link){
  link = url(link, "rb")
  result <- rvest::read_html(link, options = "RECOVER")
  close(link)
  return(result)
}

getAllLinksFolha <- function(query, year){
  search_results <- list()
  mystack <- dequer::stack()
  results <- c()
  first <- getQueryLink(query, year, "folha")
  dequer::push(mystack, first)

  p <- progressr::progressor(333)

  while(length(mystack) > 0){
    p()
    next_page <- dequer::pop(mystack)
    #message(paste0("Procesing ", next_page, "\n"))
    webpage <- getWebpage(next_page)

    news <- filterNewsPages(webpage, "folha")
    results <- c(results, news)

    nextresults <- filterNextResults(webpage)

    for(nextresult in nextresults){
      sr <- urltools::param_get(nextresult)$sr
      if(is.null(search_results[[sr]])){
        search_results[[sr]] <- TRUE
        dequer::push(mystack, nextresult)
      }
    }
  }

  return(unique(results))
}

getEstadaoQueryLink <- function(query, day, month, year){
  paste0("https://busca.estadao.com.br/?tipo_conteudo=Todos&quando=",
         day, "%2F", month, "%2F", year, "-",
         day, "%2F", month, "%2F", year,
         "&q=", query)
}

getAllLinksEstadao <- function(query, year){
  results <- vector()
  p <- progressr::progressor(372)

  for(month in 1:12){
    for(day in 1:31){
      p()
      link <- getEstadaoQueryLink(query, day, month, year)

      webpage <- try(getWebpage(link), silent = TRUE)
      if(class(webpage)[1] != "try-error"){
        news <- filterNewsPages(webpage, "estadao")
        results <- c(results, news)
      }
    }
  }
  return(unique(results))
}

#' @export
getAllLinks <- function(query, year, dirname, journal = "folha"){
  if(is.null(journal)) journal <- "folha"

  message("Fetching links")
  outputFile <- paste0(dirname, "/", year, ".txt")

  if(file.exists(outputFile)){
    message(paste0("Found local links in '", outputFile, "'"))
    return(read.table(outputFile, header = FALSE)$V1)
  }

  result <- vector()

  if(journal == "folha")
    result <- getAllLinksFolha(query, year)
  if(journal == "estadao")
    result <- getAllLinksEstadao(query, year)

  write.table(result, outputFile, row.names = FALSE, col.names = FALSE, quote = FALSE)
  return(result)
}

#' @export
downloadQuery <- function(query, years, journal = NULL){
  if(is.null(journal)) journal <- "folha"

  upperJournal <- toupper(journal)

  dirname <- paste0(upperJournal, "-", query %>% stringAsFileName())

  if(!dir.exists(dirname))
    dir.create(dirname)

  for(year in years){
    message(paste0("Processing ", year))
    getAllLinks(query, year, dirname, journal) %>%
    saveLinks(paste0(dirname, "/", year))
  }
}


