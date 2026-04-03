<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    @vite(['resources/css/app.css'])
</head>

<body>

<h1>Dashboard Customer</h1>

<p>Halo, {{ auth()->user()->name }}</p>

<a href="/">Ke Landing</a>

<form action="/logout" method="POST">
    @csrf
    <button>Logout</button>
</form>

<hr>

<h2>Explore Design</h2>

@foreach(\App\Models\Portfolio::latest()->get() as $p)
    <div class="card">
        <h3>{{ $p->title }}</h3>
        <p>Rp {{ $p->price }}</p>
    </div>
@endforeach

</body>
</html>