<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Users</title>

    {{-- LOAD CSS --}}
    @vite('resources/css/app.css')
</head>
<body class="bg-dark">

<div class="layout">

    {{-- SIDEBAR --}}
    <div class="sidebar">
        <h2>Admin</h2>
        <a href="#">Dashboard</a>
        <a href="/admin/users" class="active">Users</a>
    </div>

    {{-- MAIN --}}
    <div class="main">

        <div class="topbar">
            <h1 class="text-gradient">Manage Users</h1>
        </div>

        {{-- NOTIF --}}
        @if(session('success'))
            <p style="color:#a3e635; margin-bottom:15px;">
                {{ session('success') }}
            </p>
        @endif

        {{-- FORM TAMBAH USER --}}
        <div class="card" style="margin-bottom:20px;">
            <h3 style="margin-bottom:15px;">Tambah User</h3>

            <form action="/admin/users" method="POST">
                @csrf

                <input type="text" name="name" placeholder="Nama" required>
                <input type="email" name="email" placeholder="Email" required>
                <input type="password" name="password" placeholder="Password" required>

                <select name="role">
                    <option value="customer">Customer</option>
                    <option value="designer">Designer</option>
                    <option value="admin">Admin</option>
                </select>

                <button type="submit" class="btn" style="margin-top:10px;">
                    Tambah
                </button>
            </form>
        </div>

        {{-- TABLE USERS --}}
        <div class="card">
            <table style="width:100%; border-collapse:collapse;">

                <tr style="text-align:left; border-bottom:1px solid #334155;">
                    <th style="padding:10px;">Nama</th>
                    <th style="padding:10px;">Email</th>
                    <th style="padding:10px;">Role</th>
                    <th style="padding:10px;">Aksi</th>
                </tr>

                @foreach($users as $u)
                <tr style="border-bottom:1px solid #1e293b;">
                    <td style="padding:10px;">{{ $u->name }}</td>
                    <td style="padding:10px;">{{ $u->email }}</td>
                    <td style="padding:10px;">{{ $u->role }}</td>
                    <td style="padding:10px;">

                        {{-- EDIT --}}
                        <a href="/admin/users/{{ $u->id }}/edit"
                           class="btn"
                           style="background:#38bdf8; margin-right:5px;">
                            Edit
                        </a>

                        {{-- DELETE + ALERT --}}
                        <form action="/admin/users/{{ $u->id }}" method="POST" style="display:inline;"
                              onsubmit="return confirm('Yakin hapus user {{ $u->name }}?')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn" style="background:#ef4444;">
                                Hapus
                            </button>
                        </form>

                    </td>
                </tr>
                @endforeach

            </table>
        </div>

    </div>
</div>

</body>
</html>
