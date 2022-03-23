test_that("all", {
    result <- getQueryLink("quimica+quantica", 2020, "estadao")

    expect_equal(result, "https://busca.estadao.com.br/?tipo_conteudo=Todos&quando=01%2F01%2F2020-18%2F11%2F2020&q=quimica+quantica")

    result <- getQueryLink("quimica+quantica", 2010, "estadao")

    expect_equal(result, "https://busca.estadao.com.br/?tipo_conteudo=Todos&quando=01%2F01%2F2010-18%2F11%2F2010&q=quimica+quantica")

    result <- getQueryLink("quimica+quantica", 2020, "valor")

    expect_equal(result, "https://valor.globo.com/busca?q=quimica+quantica&page=1&order=recent&from=2020-01-01T00%3A00%3A00-0300&to=2020-12-31T23%3A59%3A59-0300")

    result <- getQueryLink("quimica+quantica", 2010, "valor")

    expect_equal(result, "https://valor.globo.com/busca?q=quimica+quantica&page=1&order=recent&from=2010-01-01T00%3A00%3A00-0300&to=2010-12-31T23%3A59%3A59-0300")

    result <- getQueryLink("quimica+quantica", 2020)

    webpage <- getWebpage(result)

    news <- filterNewsPages(webpage)

    expect_equal(length(news), 5)

    link <- news[1]

    content <- getContent(news[1])

    expect_equal(length(content), 139)

    result <- saveLink(news[1], ".")

    unlink("www1.folha.uol.com.br_mundo_2020_06_prestes-a-assumir-presidencia-da-ue-merkel-faz-de-canto-do-cisne-grande-desfecho.shtml.txt")

    saveLinks(news, "2020")

    expect_equal(length(list.files("2020")), 5)

    unlink("2020", recursive = TRUE)

    downloadQuery("quimica+quantica", 2018:2020)
    expect_equal(length(list.files("FOLHA-quimica+quantica/2018")), 2)
    expect_equal(length(list.files("FOLHA-quimica+quantica/2019")), 4)
    expect_equal(length(list.files("FOLHA-quimica+quantica/2020")), 5)

    unlink("FOLHA-quimica+quantica", recursive = TRUE)

    result <- getQueryLink("sustentabilidade", 2020)

    expect_equal(result, "https://busca.folha.uol.com.br/search?q=sustentabilidade&periodo=personalizado&sd=01%2F01%2F2020&ed=31%2F12%2F2020&site=todos")

    webpage <- getWebpage(result)

    news <- filterNewsPages(webpage)

    expect_equal(length(news), 25)

    nextresults <- filterNextResults(webpage)

    expect_equal(length(nextresults), 5)

    dir.create("sustentabilidade")
    links <- getAllLinks("sustentabilidade", 2020, "sustentabilidade")

    expect_equal(length(links), 841)
    unlink("sustentabilidade", recursive = TRUE)

    downloadQuery("quimica+quantica", 2018, "estadao")
    expect_equal(length(list.files("ESTADAO-quimica+quantica/2018")), 7)
    unlink("ESTADAO-quimica+quantica", recursive = TRUE)
})
