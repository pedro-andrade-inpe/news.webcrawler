
#' @export
filterNewsPages <- function(webpage){
  webpage %>%
    rvest::html_elements("main") %>%
    rvest::html_elements("a") %>%
    rvest::html_attr("href") %>%
    .[gdata::startsWith(., "http")] %>%
    unique()
}

#' @export
filterNextResults <- function(webpage){
  links <- filterLinks(webpage) %>%
    stringr::str_subset("search", negate = TRUE)

  return(links) #(links[nchar(links) > 66])
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
    cat(paste0("Saving link ", link, "\n"))
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
downloadQuery <- function(query, years){
  for(year in years){
      cat(paste0(">>>>> Processing ", year, " <<<<<\n"))
      getQueryLink(query, year) %>%
      getWebpage() %>%
      filterNewsPages() %>%
      saveLinks(paste(year))
  }
}

