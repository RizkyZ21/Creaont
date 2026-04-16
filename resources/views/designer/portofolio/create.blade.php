<!DOCTYPE html>
<html>
<head>
    <title>Tambah Portfolio</title>
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

        <!-- 🔥 TOP BAR (TOMBOL KANAN) -->
        <div class="topbar" style="display:flex; justify-content:space-between; align-items:center;">
            <h3>Tambah Portfolio</h3>

            <a href="/designer/dashboard" class="btn" style="background:#64748b;">
                Kembali
            </a>
        </div>

        <!-- 🔥 FORM TENGAH -->
        <div style="
            display:flex;
            justify-content:center;
            margin-top:40px;
        ">

            <div style="width:100%; max-width:500px;">

                <div class="card">

                    <form action="/designer/portfolio" method="POST" enctype="multipart/form-data">
                        @csrf

                        <!-- JUDUL -->
                        <label>Judul</label>
                        <input type="text" name="title" placeholder="Judul" required>

                        <!-- DESKRIPSI -->
                        <label>Deskripsi</label>
                        <textarea name="description" placeholder="Deskripsi"></textarea>

                        <!-- GAMBAR -->
                        <label>Gambar</label>
                        <input type="file" name="image">

                        <!-- HARGA -->
                        <label>Harga</label>
                        <input type="number" name="price" placeholder="Harga">

                        <br>

                        <!-- BUTTON -->
                        <button type="submit" class="btn">
                            Simpan
                        </button>

                    </form>

                </div>

            </div>

        </div>

    </div>
</div>

</body>
</html>
