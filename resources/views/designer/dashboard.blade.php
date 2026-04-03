<!DOCTYPE html>
<html>
<head>
    <title>Designer Dashboard</title>
    @vite(['resources/css/app.css'])
</head>

<body>

<h1>Dashboard Designer</h1>

<p>Halo Designer, {{ auth()->user()->name }}</p>

<a href="/portfolio">Kelola Portfolio</a>

<form action="/logout" method="POST">
    @csrf
    <button>Logout</button>
</form>

<hr>

<h2>Portfolio Saya</h2>

@foreach(auth()->user()->portfolios ?? [] as $p)
    <div class="card">
        <h3>{{ $p->title }}</h3>
        <p>Rp {{ $p->price }}</p>
    </div>

    
@endforeach

</body>
</html>