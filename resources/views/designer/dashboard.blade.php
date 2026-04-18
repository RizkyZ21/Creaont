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
        <a href="/designer/portfolio">📁 Portfolio</a>
        <a href="#">👤 Profile</a>
    </div>

    <!-- MAIN -->
    <div class="main">

        <!-- TOPBAR -->
        <div class="topbar">

            <h3>Hello Designer, {{ auth()->user()->name }}</h3>

            <div style="display:flex; gap:10px; align-items:center;">
                <a href="/designer/portfolio/create" class="btn">
                    + Tambah Portfolio
                </a>

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

        <!-- GRID FIX -->
        <div style="
            display:grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap:20px;
        ">

            @foreach(auth()->user()->portfolios as $p)
            <div class="card">

                <!-- GAMBAR -->
                @if($p->image)
                    <img src="{{ asset('storage/' . $p->image) }}"
                         style="width:100%; height:150px; object-fit:cover; border-radius:10px;">
                @endif

                <!-- TITLE -->
                <h3 style="margin-top:10px;">{{ $p->title }}</h3>

                <!-- PRICE -->
                <p>Rp {{ number_format($p->price, 0, ',', '.') }}</p>

                <!-- ACTION -->
                <div style="margin-top:10px; display:flex; gap:8px;">

                    <!-- EDIT -->
                    <a href="/designer/portfolio/{{ $p->id }}/edit"
                       class="btn" style="background:#38bdf8;">
                        Edit
                    </a>

                    <!-- DELETE -->
                    <form action="/designer/portfolio/{{ $p->id }}" method="POST"
                          onsubmit="return confirm('Yakin hapus portfolio {{ $p->title }}?')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn" style="background:#ef4444;">
                            Hapus
                        </button>
                    </form>

                </div>

            </div>
            @endforeach

        </div>

        @endif

    </div>
</div>

</body>
</html>
