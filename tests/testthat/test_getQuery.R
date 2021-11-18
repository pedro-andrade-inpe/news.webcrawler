test_that("getQuery", {
    result <- getQueryLink("sustentabilidade", 2020)

    expect_equal(result, "https://busca.folha.uol.com.br/search?q=sustentabilidade&periodo=personalizado&sd=01%2F01%2F2020&ed=31%2F12%2F2020&site=todos")

    result <- getQueryLink("quimica+quantica", 2020)

    webpage <- getWebpage(result)

    news <- filterNewsPages(webpage)

    expect_equal(length(news), 5)

    link <- news[1]

    content <- getContent(news[1])

    expect_equal(length(content), 151)

    result <- saveLink(news[1], ".")

    unlink("www1.folha.uol.com.br_mundo_2020_06_prestes-a-assumir-presidencia-da-ue-merkel-faz-de-canto-do-cisne-grande-desfecho.shtml.txt")

    saveLinks(news, "2020")

    expect_equal(length(list.files("2020")), 5)

    unlink("2020", recursive = TRUE)
})
