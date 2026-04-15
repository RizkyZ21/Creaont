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

        <div class="grid">
            @foreach(\App\Models\Portfolio::latest()->get() as $p)
                <div class="card">
                    <h3>{{ $p->title }}</h3>
                    <p>Rp {{ $p->price }}</p>
                    <small>{{ $p->user->name ?? '-' }}</small>
                </div>
            @endforeach
        </div>

    </div>
</div>

</body>
</html>
