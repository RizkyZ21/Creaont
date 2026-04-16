<!DOCTYPE html>
<html>
<head>
    <title>Edit Portfolio</title>
    @vite(['resources/css/app.css'])
</head>

<body class="bg-dark">

<div class="layout">

    <!-- SIDEBAR -->
    <div class="sidebar">
        <h2>Creaont</h2>
        <a href="/designer/dashboard">🏠 Dashboard</a>
        <a href="/designer/portfolio">📁 Portfolio</a>
        <a href="#">👤 Profile</a>
    </div>

    <!-- MAIN -->
    <div class="main">

        <!-- TOP -->
        <div class="topbar" style="display:flex; justify-content:space-between;">
            <h3>Edit Portfolio</h3>

            <a href="/designer/dashboard" class="btn" style="background:#64748b;">
                Kembali
            </a>
        </div>

        <!-- FORM TENGAH -->
        <div style="
            display:flex;
            justify-content:center;
            margin-top:40px;
        ">

            <div style="width:100%; max-width:500px;">

                <div class="card">

                    <form action="/designer/portfolio/{{ $portfolio->id }}" method="POST" enctype="multipart/form-data">
                        @csrf
                        @method('PUT')

                        <!-- TITLE -->
                        <label>Judul</label>
                        <input type="text" name="title" value="{{ $portfolio->title }}" required>

                        <!-- DESCRIPTION -->
                        <label>Deskripsi</label>
                        <textarea name="description">{{ $portfolio->description }}</textarea>

                        <!-- PRICE -->
                        <label>Harga</label>
                        <input type="number" name="price" value="{{ $portfolio->price }}">

                        <!-- IMAGE -->
                        <label>Gambar (optional)</label>
                        <input type="file" name="image">

                        <!-- PREVIEW -->
                        @if($portfolio->image)
                            <p style="margin-top:10px;">Gambar sekarang:</p>
                            <img src="{{ asset('storage/' . $portfolio->image) }}"
                                 style="width:100%; max-height:200px; object-fit:cover; border-radius:10px; margin-bottom:10px;">
                        @endif

                        <br>

                        <!-- BUTTON -->
                        <div style="display:flex; gap:10px;">
                            <button type="submit" class="btn">
                                Update
                            </button>

                            <a href="/designer/dashboard" class="btn" style="background:#64748b;">
                                Kembali
                            </a>
                        </div>

                    </form>

                </div>

            </div>

        </div>

    </div>
</div>

</body>
</html>
