<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    @vite(['resources/css/app.css'])
</head>

<body class="hero">

<div class="card" style="width:300px;margin:auto;">

    <h2>Login</h2>

<form action="/login" method="POST">
    @csrf

    <!-- ERROR MESSAGE -->
    @if(session('error'))
        <p style="color:red;">
            {{ session('error') }}
        </p>
    @endif

    <!-- EMAIL -->
    <input 
        type="email" 
        name="email" 
        placeholder="Email"
        value="{{ old('email') }}"
        required
    >

    <!-- PASSWORD -->
    <input 
        type="password" 
        name="password" 
        placeholder="Password"
        required
    >

    <!-- BUTTON -->
    <button type="submit">
        Login
    </button>
</form>

    <p>Belum punya akun? <a href="/register">Register</a></p>

</div>

</body>
</html>