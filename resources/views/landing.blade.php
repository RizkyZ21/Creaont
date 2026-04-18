<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Creaont</title>

    @vite(['resources/css/app.css'])

    <!-- Font -->
    <link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;600;800&display=swap" rel="stylesheet">
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar">
    <div class="nav-brand">Crea<span>ont</span></div>

    <div class="nav-links">
        <a href="/login">Login</a>
        <a href="/register" class="nav-cta">Register</a>
    </div>
</nav>

<main>

<!-- HERO -->
<section class="hero">
    <div class="hero-content">

        <span class="hero-badge">Platform desainer</span>

        <h1>
            Crea<span>ont</span>
        </h1>

        <p>
            Platform desain modern untuk kebutuhan digital Anda dengan kualitas profesional.
        </p>

    </div>
</section>

<!-- KATEGORI -->
<section class="kategori">

    <div class="hero-center">
        <span class="badge">Kategori</span>

        <h2>
            Semua Kebutuhan <br>
            <span>Desain Ada di Sini</span>
        </h2>

        <p>
            Dari logo sederhana hingga sistem branding penuh — temukan spesialis yang tepat untuk proyekmu.
        </p>
    </div>

    <div class="category-grid">
        <div class="card">🎨<p>Desain Grafis</p></div>
        <div class="card">📱<p>UI/UX Design</p></div>
        <div class="card">✏️<p>Branding & Logo</p></div>
        <div class="card">🖼️<p>Ilustrasi</p></div>
        <div class="card">🎬<p>Motion Design</p></div>
        <div class="card">🌐<p>Web Design</p></div>
        <div class="card">📊<p>Infografis</p></div>
    </div>

</section>

<!-- STEPS -->
<section class="steps">

    <span class="badge">Cara Kerja</span>

    <h2>Cara Kerja Creaont</h2>
    <p>Empat langkah mudah untuk mendapatkan desain impian Anda.</p>

    <div class="steps-grid">

        <div class="step">
            <div class="circle">01</div>
            <h3>Posting Proyek</h3>
            <p>Jelaskan kebutuhan desain Anda — kategori, brief, budget, dan deadline.</p>
        </div>

        <div class="step">
            <div class="circle">02</div>
            <h3>Terima Penawaran</h3>
            <p>Desainer terbaik mengirim proposal dan portofolio mereka.</p>
        </div>

        <div class="step">
            <div class="circle">03</div>
            <h3>Pilih & Mulai</h3>
            <p>Pilih desainer yang cocok, bayar aman melalui escrow.</p>
        </div>

        <div class="step">
            <div class="circle">04</div>
            <h3>Terima Hasil</h3>
            <p>Revisi hingga puas, lalu approve dan download hasilnya.</p>
        </div>

    </div>
</section>

<!-- PORTFOLIO -->
<section class="kategori">

    <div class="hero-center">
        <span class="badge">Trending</span>

        <h2>
            Design <span>Populer</span>
        </h2>

        <p>
            Lihat karya terbaik dari desainer pilihan.
        </p>
    </div>

    <div class="category-grid">
        @foreach($portfolios ?? [] as $p)
            <div class="card">
                <p><strong>{{ $p->title }}</strong></p>
                <p>Rp {{ $p->price }}</p>
            </div>
        @endforeach
    </div>

</section>

</main>

<!-- FOOTER -->
<footer>
    <p>© 2026 Creaont. All rights reserved.</p>
</footer>

</body>
</html>
