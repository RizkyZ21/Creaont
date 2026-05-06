# Creaont — Panduan Fix Koneksi Flutter ↔ Laravel

## File yang Harus Diganti / Ditimpa

### 📁 BACKEND (creaont-backend/)

| File | Aksi |
|---|---|
| `app/Http/Controllers/AuthController.php` | **TIMPA** — sekarang generate Sanctum token saat login/register |
| `app/Http/Controllers/OrderController.php` | **TIMPA** — pakai database nyata, bukan dummy data |
| `app/Models/Orders.php` | **TIMPA** — tambah `$fillable` dan relasi |
| `routes/api.php` | **TIMPA** — route dikelompokin: public vs protected (auth:sanctum) |

### 📁 FLUTTER (creaont_flutter/lib/)

| File | Aksi |
|---|---|
| `services/core/api_service.dart` | **TIMPA** — satu ApiService terpusat dengan platform detection |
| `services/auth/auth_service.dart` | **TIMPA** — pakai ApiService terpusat, handle response dengan benar |
| `services/order/order_service.dart` | **TIMPA** — implementasi lengkap connect ke backend |
| `services/portfolio/portfolio_service.dart` | **TIMPA** — implementasi lengkap connect ke backend |
| `services/chat/chat_service.dart` | **TIMPA** — implementasi lengkap connect ke backend |
| `providers/auth_provider.dart` | **TIMPA** — fix response key `success` (bukan `status`), simpan token |
| `lib/main.dart` | **TIMPA** — tambah named routes, auto-login dari token tersimpan |
| `core/constants/config.dart` | **TIMPA** — redirect ke `services/core/api_service.dart` |

> ⚠️ File `core/services/api_service.dart` (yang lama) bisa **dihapus** karena
> sekarang sudah digabung ke `services/core/api_service.dart`.

---

## Langkah Setup Backend

```bash
cd creaont-backend

# 1. Salin .env
cp .env.example .env
php artisan key:generate

# 2. Jalankan migrasi
php artisan migrate

# 3. Jalankan server
php artisan serve
```

---

## Cara Ganti Base URL (Fisik/Device Nyata)

Buka `lib/services/core/api_service.dart`, ubah baris ini:

```dart
// Android Emulator
return 'http://10.0.2.2:8000/api';

// Ganti ke IP lokal laptop kamu, contoh:
return 'http://192.168.1.5:8000/api';
```

Cari IP lokal laptop dengan:
- **Windows**: `ipconfig` → cari IPv4
- **Mac/Linux**: `ifconfig` → cari `inet`

---

## Masalah yang Sudah Diperbaiki

### Backend
- ✅ `login()` & `register()` sekarang return **Sanctum token**
- ✅ `OrderController` pakai database (bukan dummy data hardcoded)
- ✅ `Orders` model punya `$fillable` dan relasi ke `User` & `Portfolio`
- ✅ Routes diprotect dengan `auth:sanctum` middleware
- ✅ Tambah endpoint `/me`, `/logout`, `/update-profile`

### Flutter
- ✅ Satu `ApiService` terpusat (tidak ada duplikasi lagi)
- ✅ Platform detection otomatis (Web/Emulator/Device)
- ✅ Response key konsisten: backend dan Flutter sama-sama pakai `success`
- ✅ Token Sanctum disimpan ke `SharedPreferences` dan dikirim di setiap request
- ✅ Auto-login: jika sudah punya token, langsung masuk `/home`
- ✅ Named routes terdefinisi di `main.dart`
- ✅ `OrderService`, `PortfolioService`, `ChatService` terisi penuh
- ✅ Logout benar: hapus token di server + clear SharedPreferences

---

## Contoh Pakai di Widget (Orders)

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../services/order/order_service.dart';

Future<void> loadOrders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final res = await OrderService.getOrders(token: token);

  if (res['success'] == true) {
    final orders = res['data'] as List;
    // tampilkan ke UI
  }
}
```
