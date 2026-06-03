@php
    $downloadUrl = '#download';
@endphp

<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Creaont adalah marketplace kreatif untuk menemukan desainer, membeli karya siap pakai, dan mengelola order desain.">
    <title>Creaont - Creative Marketplace</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600,700,800" rel="stylesheet">
    <style>
        :root {
            --ink: #071a34;
            --surface: #f2f7ff;
            --muted: #5f789a;
            --line: #c9dcf2;
            --panel: #ffffff;
            --blue: #1d4ed8;
            --blue-soft: #dbeafe;
            --cyan: #0284c7;
            --sky: #38bdf8;
            --navy: #0b2a52;
            --indigo: #3b5bdb;
        }

        * {
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            margin: 0;
            color: var(--ink);
            background: var(--surface);
            font-family: "Instrument Sans", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            letter-spacing: 0;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        img {
            max-width: 100%;
            display: block;
        }

        .nav {
            position: fixed;
            inset: 0 0 auto 0;
            z-index: 20;
            border-bottom: 1px solid rgba(255, 255, 255, 0.18);
            background: rgba(7, 26, 52, 0.78);
            backdrop-filter: blur(14px);
        }

        .nav-inner {
            width: min(1160px, calc(100% - 32px));
            margin: 0 auto;
            min-height: 72px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: #fff;
            font-weight: 800;
            font-size: 20px;
        }

        .brand-mark {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: grid;
            place-items: center;
            background: #fff;
            color: var(--blue);
            font-weight: 900;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 22px;
            color: rgba(255, 255, 255, 0.82);
            font-size: 14px;
            font-weight: 600;
        }

        .nav-links a:hover {
            color: #fff;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-height: 44px;
            padding: 0 18px;
            border-radius: 8px;
            font-weight: 800;
            border: 1px solid transparent;
            transition: transform 0.2s ease, background-color 0.2s ease, border-color 0.2s ease;
        }

        .btn:hover {
            transform: translateY(-1px);
        }

        .btn-primary {
            background: #fff;
            color: var(--ink);
        }

        .btn-dark {
            background: var(--blue);
            color: #fff;
        }

        .btn-outline {
            border-color: rgba(255, 255, 255, 0.42);
            color: #fff;
        }

        .hero {
            min-height: 86vh;
            position: relative;
            display: grid;
            align-items: end;
            overflow: hidden;
            background-image:
                linear-gradient(90deg, rgba(7, 26, 52, 0.94) 0%, rgba(13, 71, 161, 0.78) 45%, rgba(14, 116, 207, 0.26) 100%),
                url("{{ asset('images/creaont-hero.png') }}");
            background-size: cover;
            background-position: center;
            color: #fff;
        }

        .hero-inner {
            width: min(1160px, calc(100% - 32px));
            margin: 0 auto;
            padding: 130px 0 58px;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #d9efff;
            font-size: 13px;
            font-weight: 800;
            text-transform: uppercase;
        }

        .eyebrow::before {
            content: "";
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--sky);
        }

        h1 {
            margin: 18px 0 18px;
            max-width: 780px;
            font-size: clamp(42px, 7vw, 86px);
            line-height: 0.98;
            font-weight: 900;
            letter-spacing: 0;
        }

        .hero-copy {
            max-width: 650px;
            color: rgba(255, 255, 255, 0.78);
            font-size: clamp(16px, 2vw, 20px);
            line-height: 1.7;
        }

        .hero-actions {
            margin-top: 30px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .hero-metrics {
            margin-top: 46px;
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 150px));
            gap: 12px;
        }

        .metric {
            border-left: 2px solid rgba(255, 255, 255, 0.32);
            padding-left: 14px;
        }

        .metric strong {
            display: block;
            font-size: 25px;
            color: #fff;
        }

        .metric span {
            color: rgba(255, 255, 255, 0.68);
            font-size: 13px;
        }

        .section {
            width: min(1160px, calc(100% - 32px));
            margin: 0 auto;
            padding: 64px 0;
        }

        .section-head {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 24px;
            margin-bottom: 24px;
        }

        .section-title {
            margin: 0;
            max-width: 660px;
            font-size: clamp(30px, 4vw, 48px);
            line-height: 1.06;
            font-weight: 900;
        }

        .section-note {
            max-width: 360px;
            color: var(--muted);
            line-height: 1.65;
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 14px;
        }

        .feature {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 22px;
            min-height: 210px;
        }

        .feature-icon {
            width: 44px;
            height: 44px;
            border-radius: 8px;
            display: grid;
            place-items: center;
            color: #fff;
            font-weight: 900;
            margin-bottom: 20px;
        }

        .feature:nth-child(1) .feature-icon { background: var(--blue); }
        .feature:nth-child(2) .feature-icon { background: var(--cyan); }
        .feature:nth-child(3) .feature-icon { background: var(--indigo); }
        .feature:nth-child(4) .feature-icon { background: var(--navy); }

        .feature h3 {
            margin: 0 0 10px;
            font-size: 18px;
        }

        .feature p {
            margin: 0;
            color: var(--muted);
            line-height: 1.6;
        }

        .feature-action {
            display: block;
            margin-top: 18px;
        }

        .band {
            background: #08213f;
            color: #fff;
        }

        .workflow {
            display: grid;
            grid-template-columns: 0.9fr 1.1fr;
            gap: 42px;
            align-items: center;
        }

        .workflow-steps {
            display: grid;
            gap: 12px;
        }

        .step {
            display: grid;
            grid-template-columns: 48px 1fr;
            gap: 16px;
            align-items: start;
        }

        .step-number {
            height: 48px;
            border-radius: 8px;
            display: grid;
            place-items: center;
            background: var(--blue-soft);
            color: var(--blue);
            font-weight: 900;
        }

        .step h3 {
            margin: 0 0 6px;
            font-size: 18px;
        }

        .step p {
            margin: 0;
            color: #c8d4df;
            line-height: 1.6;
        }

        .cta {
            padding: 72px 0;
            background: #ffffff;
            border-top: 1px solid var(--line);
        }

        .cta-inner {
            width: min(1160px, calc(100% - 32px));
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            gap: 24px;
            align-items: center;
        }

        .cta h2 {
            margin: 0;
            max-width: 650px;
            font-size: clamp(30px, 4vw, 52px);
            line-height: 1.05;
        }

        footer {
            background: var(--ink);
            color: rgba(255, 255, 255, 0.68);
            padding: 28px 0;
        }

        .footer-inner {
            width: min(1160px, calc(100% - 32px));
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }

        @media (max-width: 900px) {
            .nav-links a:not(.btn) {
                display: none;
            }

            .hero {
                min-height: 82vh;
                background-position: 58% center;
            }

            .hero-metrics,
            .feature-grid,
            .workflow,
            .cta-inner {
                grid-template-columns: 1fr;
            }

            .section-head,
            .cta-inner {
                align-items: start;
                flex-direction: column;
            }
        }

        @media (max-width: 560px) {
            .nav-inner {
                min-height: 64px;
            }

            .brand {
                font-size: 18px;
            }

            .hero-inner {
                padding-top: 112px;
            }

            .hero-actions .btn {
                width: 100%;
            }

            .hero-metrics {
                grid-template-columns: 1fr;
                margin-top: 34px;
            }

            .feature {
                min-height: auto;
            }
        }
    </style>
</head>
<body>
    <header class="nav" aria-label="Main navigation">
        <div class="nav-inner">
            <a class="brand" href="/">
                <span class="brand-mark">C</span>
                <span>Creaont</span>
            </a>
            <nav class="nav-links">
                <a href="#features">Fitur</a>
                <a href="#workflow">Alur</a>
                <a class="btn btn-primary" href="{{ $downloadUrl }}">Download Sekarang</a>
            </nav>
        </div>
    </header>

    <main>
        <section class="hero">
            <div class="hero-inner">
                <span class="eyebrow">Creative marketplace</span>
                <h1>Creaont</h1>
                <p class="hero-copy">
                    Platform untuk menemukan desainer, membeli karya siap pakai, memesan jasa kreatif, dan mengelola progres order dalam satu pengalaman yang jelas.
                </p>
                <div class="hero-actions">
                    <a class="btn btn-primary" href="{{ $downloadUrl }}">Download Sekarang</a>
                    <a class="btn btn-outline" href="{{ route('admin.login') }}">Masuk Admin</a>
                </div>
                <div class="hero-metrics" aria-label="Creaont highlights">
                    <div class="metric">
                        <strong>2</strong>
                        <span>Mode transaksi: desain jadi dan jasa</span>
                    </div>
                    <div class="metric">
                        <strong>Live</strong>
                        <span>Order, chat, payment, dan delivery</span>
                    </div>
                    <div class="metric">
                        <strong>Admin</strong>
                        <span>Dashboard operasional lengkap</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="section" id="features">
            <div class="section-head">
                <h2 class="section-title">Marketplace desain yang dibangun untuk transaksi nyata.</h2>
                <p class="section-note">
                    Creaont menyatukan katalog portfolio, order, pembayaran, chat, file delivery, dan admin panel agar proses kreatif lebih mudah dipantau.
                    <span class="feature-action">
                        <a class="btn btn-dark" href="{{ route('admin.login') }}">Masuk Admin</a>
                    </span>
                </p>
            </div>

            <div class="feature-grid">
                <article class="feature">
                    <div class="feature-icon">01</div>
                    <h3>Portfolio & kategori</h3>
                    <p>Admin mengelola kategori, designer mengunggah karya, dan customer menelusuri pilihan yang relevan.</p>
                </article>
                <article class="feature">
                    <div class="feature-icon">02</div>
                    <h3>Order terstruktur</h3>
                    <p>Status, progress, deadline, dan detail customer/designer tampil jelas di aplikasi dan dashboard admin.</p>
                </article>
                <article class="feature">
                    <div class="feature-icon">03</div>
                    <h3>Pembayaran</h3>
                    <p>Integrasi payment membantu pembelian desain jadi dan layanan kreatif berjalan dengan status yang mudah dicek.</p>
                </article>
                <article class="feature">
                    <div class="feature-icon">04</div>
                    <h3>File delivery</h3>
                    <p>Designer bisa mengirim hasil pekerjaan dan customer dapat mengunduh file sesuai order yang sudah selesai.</p>
                </article>
            </div>
        </section>

        <section class="band" id="workflow">
            <div class="section workflow">
                <div>
                    <span class="eyebrow">Workflow</span>
                    <h2 class="section-title">Dari pencarian sampai file terkirim.</h2>
                    <p class="section-note" style="color:#c8d4df;">
                        Alur Creaont dibuat singkat untuk customer, tetapi tetap memberi ruang kontrol bagi designer dan admin.
                    </p>
                </div>
                <div class="workflow-steps">
                    <div class="step">
                        <div class="step-number">1</div>
                        <div>
                            <h3>Pilih karya atau jasa</h3>
                            <p>Customer menelusuri portfolio berdasarkan kategori dan membuka detail layanan.</p>
                        </div>
                    </div>
                    <div class="step">
                        <div class="step-number">2</div>
                        <div>
                            <h3>Buat order dan bayar</h3>
                            <p>Order dibuat dari portfolio pilihan, lalu status pembayaran dan progres dapat dipantau.</p>
                        </div>
                    </div>
                    <div class="step">
                        <div class="step-number">3</div>
                        <div>
                            <h3>Diskusi dan serah terima</h3>
                            <p>Chat order, revisi, file hasil, dan riwayat status tersimpan dalam satu alur.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="cta" id="download">
            <div class="cta-inner">
                <h2>Download aplikasi Creaont untuk mulai transaksi desain.</h2>
                <a class="btn btn-dark" href="{{ $downloadUrl }}">Download Sekarang</a>
            </div>
        </section>
    </main>

    <footer>
        <div class="footer-inner">
            <span>Creaont Creative Marketplace</span>
            <span>Laravel backend, Flutter app, admin dashboard.</span>
        </div>
    </footer>
</body>
</html>
