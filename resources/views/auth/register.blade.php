<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    @vite(['resources/css/app.css'])
</head>

<body class="hero">

<div class="card" style="width:300px;margin:auto;">

    <h2>Register</h2>

<form method="POST" action="/register">
        @csrf

        <input type="text" name="name" placeholder="Nama" required><br><br>
        <input type="email" name="email" placeholder="Email" required><br><br>

        <select name="role">
            <option value="customer">Customer</option>
            <option value="designer">Designer</option>
        </select><br><br>

        <input type="password" name="password" placeholder="Password" required><br><br>

        <button class="btn">Register</button>
    </form>

    <p>Sudah punya akun? <a href="/login">Login</a></p>

</div>

</body>
</html>