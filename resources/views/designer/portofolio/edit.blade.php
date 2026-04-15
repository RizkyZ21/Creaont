<!DOCTYPE html>
<html>
<head>
    <title>Edit Portfolio</title>
    @vite(['resources/css/app.css'])
</head>

<body class="bg-dark">

<div class="flex-center">

    <div class="auth-card">

        <h2>Edit Portfolio</h2>
        <br>

        @if ($errors->any())
            <div style="color:red;">
                @foreach ($errors->all() as $e)
                    <p>{{ $e }}</p>
                @endforeach
            </div>
        @endif

        <form action="/portfolio/{{ $portfolio->id }}/update" method="POST">
            @csrf

            <label>Judul</label>
            <input type="text" name="title" value="{{ $portfolio->title }}" required>

            <br><br>

            <label>Harga</label>
            <input type="number" name="price" value="{{ $portfolio->price }}" required>

            <br><br>

            <label>Deskripsi</label>
            <textarea name="description" rows="4">{{ $portfolio->description }}</textarea>

            <br><br>

            <button class="btn">Update</button>

        </form>

    </div>

</div>

</body>
</html>