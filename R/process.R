
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

  return(fullQuery)
}

#' @export
saveLinks <- function(links, directory){
  if(!dir.exists(directory))
    dir.create(directory)

  for(link in links){
    message(paste0("Saving link ", link, "\n"))
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

#' @export
saveLink <- function(link, directory){
  filename <- substr(link, 9, nchar(link)) %>%
    stringr::str_replace_all("/", "_") %>%
    stringr::str_replace_all("\\?", "_") %>%
    stringr::str_replace_all("=", "_") %>%
    paste0(".txt")

  outputFile <- paste0(directory, "/", filename)
  content <- getContent(link)
  write.table(content, outputFile, row.names = FALSE, col.names = FALSE, quote = FALSE)
}

#' @export
getWebpage <- function(link){ #, year, outputDir = "result"){
  webpage <- rvest::read_html(link)
  return(webpage)
}

#' @export
getAllLinks <- function(query, year){
  search_results <- list()
  mystack <- dequer::stack()
  results <- c()
  first <- getQueryLink(query, year)
  dequer::push(mystack, first)

  while(length(mystack) > 0){
    next_page <- dequer::pop(mystack)
    message(paste0("Procesing ", next_page, "\n"))
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

  return(unique(results))
}

#' @export
downloadQuery <- function(query, years){
  for(year in years){
      message(paste0(">>>>> Processing ", year, " <<<<<\n"))
      getQueryLink(query, year) %>%
      getWebpage() %>%
      filterNewsPages() %>%
      saveLinks(paste(year))
  }
}

