
utils::globalVariables(c(".", "%>%", ":="))

#' @importFrom magrittr %>%
NULL

.onAttach <- function(lib, pkg){
  packageStartupMessage(sprintf("news.webcrawler version %s is now loaded",
                                utils::packageDescription("news.webcrawler")$Version))
}
