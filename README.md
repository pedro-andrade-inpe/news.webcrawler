# news.webcrawler

Package that implements a webcrawler to download news published by Brazilian companies. For now it works only with FSP. All the data collected using this software will be used only with scientific purposes.

To install the package:

```R
install.packages("devtools")

devtools::install_github("pedro-andrade-inpe/news.webcrawler", upgrade = "always")
```

To download all news containing "procrastinar" from 2018 to 2020, in separate folders by year.

```R
progressr::handlers(global = TRUE)

news.webcrawler::downloadQuery("procrastinar", 2018:2020)
```

If the connection fails and the command stop without reading all files, you can just run it again and it will continue from the last successfull download.

To use more than one keyword, use `+` instead of ` `:

```R
news.webcrawler::downloadQuery("ciclo+nitrogenio", 2015:2020)
```
