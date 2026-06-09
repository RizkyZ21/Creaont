# Creaont

Creaont terdiri dari 2 folder project:

- **creaont-backend** (Laravel API)
- **creaont_flutter** (Flutter Mobile App)

## Clone Repository

```bash
git clone https://github.com/RizkyZ21/Creaont.git
cd Creaont
```

## Backend (Laravel)

Masuk ke folder backend:

```bash
cd creaont-backend
```

Install dependency:

```bash
composer install
```

Copy file environment:

```bash
cp .env.example .env
```

Generate application key:

```bash
php artisan key:generate
```

Sesuaikan konfigurasi database pada file `.env`.

### Buat Admin User (Opsional untuk Testing)

Jalankan Tinker:

```bash
php artisan tinker
```

Kemudian buat akun admin:

```php
App\Models\User::create([
    'name' => 'Admin',
    'email' => 'admin@gmail.com',
    'password' => bcrypt('password123'),
    'role' => 'admin',
]);
```

Lalu jalankan:

```bash
php artisan migrate --seed
php artisan storage:link
php artisan serve
```

Backend akan berjalan di:

```text
http://127.0.0.1:8000
```

## Frontend (Flutter)

Masuk ke folder Flutter:

```bash
cd creaont_flutter
```

Install dependency:

```bash
flutter pub get
```

Pastikan `baseUrl` pada file konfigurasi mengarah ke backend yang sedang berjalan.

Jalankan aplikasi:

```bash
flutter run
```

## Struktur Folder

```text
Creaont/
├── creaont-backend/
└── creaont_flutter/
```

## Kelompok 4
- **Damar Wisnu Angjaya**
- **Muhammad Rizky Zuhriansyah**
- **Muhammad Labib Irfani**