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
        <h2>Designer</h2>

        <a href="/designer/dashboard">Dashboard</a>
        <a href="/portfolio/create">+ Tambah Portfolio</a>

        <form action="/logout" method="POST">
            @csrf
            <button class="btn" style="margin-top:20px;">Logout</button>
        </form>
    </div>

    <!-- MAIN -->
    <div class="main">

        <!-- TOPBAR -->
        <div class="topbar">
            <h1>Dashboard</h1>
            <p>Halo, {{ auth()->user()->name }}</p>
        </div>

        <hr><br>

        <h2>Portfolio Saya</h2>

        <br>

        <!-- GRID PORTFOLIO -->
        <div class="grid">

            @forelse(auth()->user()->portfolios as $p)
                <div class="card">
                    <h3>{{ $p->title }}</h3>
                    <p>Rp {{ $p->price }}</p>

                    <br>

                    <!-- TOMBOL -->
                    <a href="/portfolio/{{ $p->id }}/edit" class="btn">
                        Edit
                    </a>
                </div>
            @empty
                <p>Belum ada portfolio 😢</p>
            @endforelse

        </div>

    </div>

</div>

</body>
</html>
