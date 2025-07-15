output$homeText <- renderText({
  glue::glue(
    "<body>
    <header>
    <h1>Interactive Data Analytics Center</h1>
    </header>
    <main>
    <h3>Tentang Kami</h3>
    <p>Interactive Data Analytics Center (iDANCE) adalah sebuah platform analitik data interaktif yang dikembangkan untuk membantu proses eksplorasi, visualisasi, dan analisis data secara efisien dan intuitif. iDANCE dirancang untuk mendukung pengambilan keputusan berbasis data melalui berbagai fitur seperti pemilihan fitur otomatis, analisis cluster interaktif, serta representasi data dalam bentuk grafik jaringan.</p>
    
    <h3>Modul-Modul Dashboard iDANCE</h3>
    <div style='margin-left: 20px;'>
    
    <p><strong>🔗 Interactive Clustering</strong><br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Modul untuk melakukan analisis clustering secara interaktif dengan algoritma K-Means. Pengguna dapat mengeksplorasi hasil clustering dengan visualisasi yang dinamis dan dapat disesuaikan.</p>
    
    <p><strong>📊 Network Graph</strong><br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fitur untuk memvisualisasikan hubungan antar data dalam bentuk grafik jaringan (network graph). Modul ini memungkinkan eksplorasi pola koneksi dan hubungan kompleks dalam dataset dengan tampilan interaktif.</p>
    
    <p><strong>📈 Regression</strong><br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Modul analisis regresi yang menyediakan analisis data dengan teknik regresi seperti Linear Regression. Dilengkapi dengan visualisasi hasil prediksi dan hasil analisis berdasarkan gemini.</p>
    
    <p><strong>👥 Fuzzy Duplicate</strong><br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sistem deteksi duplikasi data menggunakan algoritma fuzzy matching untuk mengidentifikasi record yang mirip atau berpotensi duplikat. Berguna untuk pembersihan data dan peningkatan kualitas dataset.</p>
    
    <p><strong>🔍 Benford Analysis</strong><br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Implementasi Hukum Benford untuk deteksi anomali dalam dataset numerik. Modul ini berguna untuk audit data, deteksi fraud, dan verifikasi keaslian data berdasarkan distribusi digit pertama.</p>
    
    <p><strong>💬 WhatsApp Analysis</strong><br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fitur untuk menganalisis data percakapan WhatsApp, termasuk analisis sentimen, pola komunikasi, statistik pesan, dan visualisasi aktivitas chat dalam periode waktu tertentu.</p>
    
    <p><strong>📋 Statistical Sampling</strong><br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Alat untuk melakukan sampling statistik dengan berbagai metode seperti Simple Random Sampling, Stratified Sampling, dan Systematic Sampling. Modul ini membantu dalam pemilihan sampel yang representatif dari populasi data.</p>
    
    </div>
    
    </main>
    </body>")
})
