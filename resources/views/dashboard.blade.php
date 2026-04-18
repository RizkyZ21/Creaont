<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    @vite(['resources/css/app.css'])
</head>

<body class="bg-dark">

<div class="layout">

    <!-- SIDEBAR -->
    <div class="sidebar">
        <h2>Creaont</h2>
        <a href="#">🏠 Dashboard</a>
        <a href="#">🎨 Explore</a>
        <a href="#">👤 Profile</a>
    </div>

    <!-- MAIN -->
    <div class="main">

        <!-- TOPBAR -->
        <div class="topbar">
            <h3>Welcome, {{ auth()->user()->name }}</h3>

            <form action="/logout" method="POST">
                @csrf
                <button class="btn">Logout</button>
            </form>
        </div>

        <!-- CONTENT -->
        <h2>Explore Design</h2>

        <br>

        <!-- GRID -->
        <div style="
            display:grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap:20px;
        ">

            @foreach(\App\Models\Portfolio::latest()->get() as $p)
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

                <!-- DESIGNER -->
                <small style="color:#94a3b8;">
                    by {{ $p->user->name ?? '-' }}
                </small>

            </div>
            @endforeach

        </div>

    </div>
</div>

</body>
</html>
