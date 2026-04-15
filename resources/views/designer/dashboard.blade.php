<!DOCTYPE html>
<html>
<head>
    <title>Designer Dashboard</title>
    @vite(['resources/css/app.css'])
</head>

<body class="bg-dark">

<div class="layout">

    <!-- SIDEBAR -->
    <div class="sidebar">
        <h2>Creaont</h2>
        <a href="#">🏠 Dashboard</a>
        <a href="/portfolio">📁 Portfolio</a>
        <a href="#">👤 Profile</a>
    </div>

    <!-- MAIN -->
    <div class="main">

        <!-- TOPBAR -->
        <div class="topbar">

            <!-- KIRI -->
            <h3>Hello Designer, {{ auth()->user()->name }}</h3>

            <!-- KANAN -->
            <div style="display:flex; gap:10px; align-items:center;">

                <!-- TOMBOL TAMBAH -->
                <a href="/designer/portfolio/create" class="btn">
                    + Tambah Portfolio
                </a>

                <!-- LOGOUT -->
                <form action="/logout" method="POST">
                    @csrf
                    <button class="btn">Logout</button>
                </form>

            </div>
        </div>

        <!-- CONTENT -->
        <h2>Portfolio Saya</h2>

        <br>

        @if(auth()->user()->portfolios->isEmpty())
            <p>Belum ada portfolio</p>
        @else
            <div class="grid">
                @foreach(auth()->user()->portfolios as $p)
                    <div class="card">
                        <h3>{{ $p->title }}</h3>
                        <p>Rp {{ $p->price }}</p>
                    </div>
                @endforeach
            </div>
        @endif

    </div>
</div>

</body>
</html>
