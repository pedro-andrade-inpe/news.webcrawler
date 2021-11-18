# news.webcrawler

Package that implements a webcrawler to download news published by Brazilian companies. For now it works only with Folha de Sao Paulo.

To install the package:

```R
install.packages("devtools")

devtools::install_github("pedro-andrade-inpe/news.webcrawler", upgrade = "always")
```

To download all news containing "sustentabilidade" from 2018 to 2020, in separate folders by year.

```R
progressr::handlers(global = TRUE)

news.webcrawler::downloadQuery("sustentabilidade", 2018:2020)
```
