<form method="POST" enctype="multipart/form-data">
    @csrf
    <input name="title" placeholder="Judul">
    <textarea name="description"></textarea>
    <input type="file" name="image">
    <input name="price" placeholder="Harga">
    <button type="submit">Simpan</button>
</form>