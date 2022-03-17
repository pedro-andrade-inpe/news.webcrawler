
#' @export
filterNewsPages <- function(webpage){
  webpage %>%
    rvest::html_elements("main") %>%
    rvest::html_elements("a") %>%
    rvest::html_attr("href") %>%
    .[gdata::startsWith(., "http")] %>%
    stringr::str_subset("search", negate = TRUE) %>%
    unique()
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
getQueryLink <- function(query, year){
  fullQuery <- paste0("https://busca.folha.uol.com.br/search?q=",
                      query,
                      "&periodo=personalizado&sd=01%2F01%2F",
                      year,
                      "&ed=31%2F12%2F",
                      year,
                      "&site=todos")

#  https://busca.estadao.com.br/?tipo_conteudo=Todos&quando=01%2F01%2F2010-18%2F11%2F2010&q=fisica%20quantica

#  https://valor.globo.com/busca?q=fisica+quantica&page=1&order=recent&from=2021-01-01T00%3A00%3A00-0300&to=2021-11-18T23%3A59%3A59-0300

  return(fullQuery)
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
    write.table(content, outputFile, row.names = FALSE, col.names = FALSE, quote = FALSE, encoding = "UTF-8")
  }
}

#' @export
getWebpage <- function(link){
  return(rvest::read_html(link))
}

#' @export
getAllLinks <- function(query, year, dirname){
  message("Fetching links")
  outputFile <- paste0(dirname, "/", year, ".txt")

  if(file.exists(outputFile)){
    message(paste0("Found local links in '", outputFile, "'"))
    return(read.table(outputFile, header =FALSE)$V1)
  }

  search_results <- list()
  mystack <- dequer::stack()
  results <- c()
  first <- getQueryLink(query, year)
  dequer::push(mystack, first)

  p <- progressr::progressor(333)

  while(length(mystack) > 0){
    p()
    next_page <- dequer::pop(mystack)
    #message(paste0("Procesing ", next_page, "\n"))
    webpage <- getWebpage(next_page)

    news <- filterNewsPages(webpage)
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

  result <- unique(results)
  write.table(result, outputFile, row.names = FALSE, col.names = FALSE, quote = FALSE)
  return(result)
}

#' @export
downloadQuery <- function(query, years){
  dirname <- paste0("FSP-", query %>% stringAsFileName())

  if(!dir.exists(dirname))
    dir.create(dirname)

  for(year in years){
    message(paste0("Processing ", year))
    getAllLinks(query, year, dirname) %>%
    saveLinks(paste0(dirname, "/", year))
  }
}
