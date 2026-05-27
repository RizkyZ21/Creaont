# Admin Panel Setup & Access Guide

## Akses Admin Panel

Admin panel sudah terbuat dan dapat diakses di: **http://localhost:8000/admin/dashboard**

### Fitur yang Tersedia

1. **Dashboard**
   - Ringkasan statistik (total users, orders, revenue, dll)
   - Daftar 10 order terbaru dengan status dan progress

2. **Users Management**
   - Lihat semua users (customer, designer, admin)
   - Edit user information (name, email, role)
   - Hapus user

3. **Orders Management**
   - Lihat semua orders dengan detail customer dan designer
   - View detail order
   - Update status order (pending, in_progress, revision, completed, cancelled)
   - Update progress order (0-100%)

4. **Portfolios Management**
   - Lihat semua portfolio dari designer
   - Hapus portfolio

5. **Chats Monitoring**
   - Lihat semua chat/message antar customer dan designer
   - Monitor komunikasi real-time

6. **Reviews Management**
   - Lihat semua reviews/rating dari customer ke designer
   - Lihat rating dan comment

7. **Analytics & Reports**
   - Chart orders by month (line chart)
   - Chart revenue by month (bar chart)
   - Top 10 designers berdasarkan orders dan revenue

### Setup & Instalasi

#### 1. Jalankan Migrations (jika belum)
```bash
cd creaont-backend
php artisan migrate
```

#### 2. Buat Admin User (untuk testing)

Gunakan Tinker:
```bash
php artisan tinker
```

Kemudian jalankan:
```php
App\Models\User::create([
    'name' => 'Admin',
    'email' => 'admin@gmail.com',
    'password' => bcrypt('password123'),
    'role' => 'admin',
]);
```

#### 3. Jalankan Laravel Server
```bash
php artisan serve
```

#### 4. Akses Admin Panel

**URL:** http://localhost:8000/admin/dashboard

**Login dengan:**
- Email: `admin@example.com`
- Password: `password123`

### Struktur Folder

```
resources/
├── views/
│   └── admin/
│       ├── layouts/
│       │   └── app.blade.php          (Main layout dengan sidebar)
│       └── pages/
│           ├── dashboard.blade.php    (Dashboard utama)
│           ├── users.blade.php        (User management)
│           ├── orders.blade.php       (Orders list)
│           ├── view-order.blade.php   (Order detail & update)
│           ├── portfolios.blade.php   (Portfolios list)
│           ├── chats.blade.php        (Chat monitoring)
│           ├── reviews.blade.php      (Reviews list)
│           ├── analytics.blade.php    (Analytics & reports)
│           ├── edit-user.blade.php    (Edit user form)
│           └── login.blade.php        (Admin login)

app/
├── Http/
│   ├── Controllers/
│   │   └── AdminController.php        (Admin logic)
│   └── Middleware/
│       └── CheckAdmin.php             (Auth middleware)
```

### Routes

Semua routes admin dilindungi oleh middleware `auth` dan `admin`:

```
GET    /admin/dashboard                    - Dashboard
GET    /admin/users                        - List users
GET    /admin/users/{id}/edit              - Edit user form
PUT    /admin/users/{id}                   - Update user
DELETE /admin/users/{id}                   - Delete user
GET    /admin/orders                       - List orders
GET    /admin/orders/{id}                  - View order detail
PUT    /admin/orders/{id}/status           - Update order status
GET    /admin/portfolios                   - List portfolios
DELETE /admin/portfolios/{id}              - Delete portfolio
GET    /admin/chats                        - Monitor chats
GET    /admin/reviews                      - List reviews
GET    /admin/analytics                    - Analytics page
```

### Styling & Design

Admin panel menggunakan:
- **Bootstrap 5** untuk responsive layout
- **Font Awesome 6** untuk icons
- **Chart.js** untuk visualisasi data (di analytics page)
- Custom CSS dengan gradient dan shadows untuk UI yang modern

### TODO (Future Enhancements)

- [ ] Implement authentication controller untuk login/logout
- [ ] Add payment management page
- [ ] Add revision management page
- [ ] Add design file management page
- [ ] Add invoice management & generation
- [ ] Real-time notifications
- [ ] Export to PDF/Excel reports
- [ ] Dark mode support
- [ ] Two-factor authentication

### Support

Jika ada error, pastikan:
1. Database sudah siap dengan migrations
2. Admin user sudah dibuat
3. PHP version minimal 8.3
4. Semua dependencies sudah install via `composer install`
