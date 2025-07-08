output$homeText <- renderText({
  glue::glue(
    "<body>
    <header>
    <h1>Interactive Data Analytics Center</h1>
    </header>
    <main>
    <h3>Tentang Kami</h3>
    <p>Interactive Data Analytics Center (iDANCE) adalah Interactive Data Analytics Center (iDANCE) adalah sebuah platform analitik data interaktif yang dikembangkan untuk membantu proses eksplorasi, visualisasi, dan analisis data secara efisien dan intuitif. iDANCE dirancang untuk mendukung pengambilan keputusan berbasis data melalui berbagai fitur seperti pemilihan fitur otomatis, analisis cluster interaktif, serta representasi data dalam bentuk grafik jaringan.</p>

    </main>
    </body>")
})
