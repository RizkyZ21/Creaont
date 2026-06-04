<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make('password');

        $users = [
            [
                'name' => 'Test User',
                'email' => 'test@example.com',
                'role' => 'customer',
                'bio' => 'Akun customer umum untuk testing login dan transaksi.',
            ],
            [
                'name' => 'Bima Pratama',
                'email' => 'bima.customer@creaont.test',
                'role' => 'customer',
                'bio' => 'Pemilik UMKM yang sering mencari desain promosi.',
            ],
            [
                'name' => 'Salsa Kirana',
                'email' => 'salsa.customer@creaont.test',
                'role' => 'customer',
                'bio' => 'Customer yang fokus pada kebutuhan branding produk.',
            ],
            [
                'name' => 'Nadia Studio',
                'email' => 'nadia.designer@creaont.test',
                'role' => 'designer',
                'bio' => 'Designer UI/UX dan social media kit.',
            ],
            [
                'name' => 'Raka Visual',
                'email' => 'raka.designer@creaont.test',
                'role' => 'designer',
                'bio' => 'Spesialis logo, ilustrasi, dan brand identity.',
            ],
            [
                'name' => 'Maya Motion',
                'email' => 'maya.designer@creaont.test',
                'role' => 'designer',
                'bio' => 'Designer motion graphic untuk campaign digital.',
            ],
            [
                'name' => 'Demo Admin',
                'email' => 'demo.admin@creaont.test',
                'role' => 'admin',
                'bio' => 'Akun admin tambahan untuk demo panel.',
            ],
        ];

        foreach ($users as $user) {
            User::updateOrCreate(
                ['email' => $user['email']],
                [
                    'name' => $user['name'],
                    'role' => $user['role'],
                    'bio' => $user['bio'],
                    'avatar' => null,
                    'password' => $password,
                ],
            );
        }
    }
}
