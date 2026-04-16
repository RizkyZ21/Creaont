<!DOCTYPE html>
<html>
<head>
    <title>Edit Portfolio</title>
    @vite(['resources/css/app.css'])
</head>

<body class="bg-dark">

<div class="container">

    <h2>Edit Portfolio</h2>

    <!-- UPDATE -->
    <form action="/designer/portfolio/{{ $portfolio->id }}/update" method="POST">
        @csrf

        <input type="text" name="title" value="{{ $portfolio->title }}"><br><br>

        <textarea name="description">{{ $portfolio->description }}</textarea><br><br>

        <input type="number" name="price" value="{{ $portfolio->price }}"><br><br>

        <button class="btn">Update</button>
    </form>

    <br>

    <!-- DELETE -->
    <form action="/designer/portfolio/{{ $portfolio->id }}/delete" method="POST">
        @csrf
        @method('DELETE')

        <button class="btn" style="background:red;color:white;">
            Hapus Portfolio
        </button>
    </form>

    <br>

    <a href="/designer/dashboard">← Kembali</a>

</div>

</body>
</html>