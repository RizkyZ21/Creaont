<!DOCTYPE html>
<html>
<head>
    <title>Tambah Desain</title>
    @vite(['resources/css/app.css'])
</head>

<body class="bg-dark">

<div class="container">

    <h2>Tambah Desain</h2>

    <!-- ✅ FIX ACTION -->
    <form action="/designer/portfolio/store" method="POST" enctype="multipart/form-data">
        @csrf

        <input type="text" name="title" placeholder="Judul desain"><br><br>

        <textarea name="description" placeholder="Deskripsi"></textarea><br><br>

        <input type="number" name="price" placeholder="Harga"><br><br>

        <input type="file" name="image"><br><br>

        <button class="btn">Upload</button>
    </form>

</div>

</body>
</html>