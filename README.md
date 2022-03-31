# news.webcrawler

Package that implements a webcrawler to download news published by Brazilian companies. It works with the following journals: "folha" (Folha de S. Paulo), "estadao" (Estadão), and "valor" (Valor Econômico). All the data collected using this software will be used only with scientific purposes.

To install the package:

```R
install.packages("devtools")

devtools::install_github("pedro-andrade-inpe/news.webcrawler", upgrade = "always")
```

To download all news from "folha" and "estadao" containing "procrastinar" from 2018 to 2020, in separate folders by year.

```R
progressr::handlers(global = TRUE)

news.webcrawler::downloadQuery("procrastinar", 2018:2020, "folha")

news.webcrawler::downloadQuery("procrastinar", 2018:2020, "estadao")

news.webcrawler::downloadQuery("procrastinar", 2018:2020, "valor")
```

If the connection fails and the command stop without reading all files, you can just run it again and it will continue from the last successful download.

To use more than one keyword, use `+` instead of ` `:

```R
news.webcrawler::downloadQuery("ciclo+nitrogenio", 2015:2020)
```
