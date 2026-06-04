<?php

namespace Database\Seeders;

use App\Models\Orders;
use App\Models\Portfolio;
use App\Models\User;
use App\Notifications\NewMessageNotification;
use App\Notifications\OrderPlacedNotification;
use App\Notifications\ProgressUpdatedNotification;
use App\Notifications\RatingReceivedNotification;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class NotificationSeeder extends Seeder
{
    public function run(): void
    {
        $customer = User::updateOrCreate(
            ['email' => 'customer@creaont.test'],
            [
                'name' => 'Creaont Customer',
                'role' => 'customer',
                'password' => Hash::make('password'),
            ],
        );

        $designer = User::updateOrCreate(
            ['email' => 'designer@creaont.test'],
            [
                'name' => 'Creaont Designer',
                'role' => 'designer',
                'password' => Hash::make('password'),
                'bio' => 'Designer UI/UX dan branding untuk kebutuhan demo notifikasi.',
            ],
        );

        $portfolio = Portfolio::updateOrCreate(
            [
                'user_id' => $designer->id,
                'title' => 'Landing Page Modern',
            ],
            [
                'description' => 'Desain landing page premium untuk startup dan produk digital.',
                'category' => 'UI/UX',
                'type' => 'service',
                'price' => 750000,
                'image' => null,
            ],
        );

        $order = Orders::updateOrCreate(
            [
                'customer_id' => $customer->id,
                'designer_id' => $designer->id,
                'portfolio_id' => $portfolio->id,
            ],
            [
                'description' => 'Butuh landing page untuk campaign produk baru.',
                'status' => 'in_progress',
                'type' => 'service',
                'progress' => 65,
                'deadline' => now()->addDays(7)->toDateString(),
                'estimated_days' => 7,
                'total_price' => 750000,
                'payment_status' => 'paid',
                'payment_reference' => 'SEED-NOTIF-' . $customer->id . '-' . $designer->id,
            ],
        );

        foreach ([$customer, $designer] as $user) {
            $user->notifications()
                ->where('data', 'like', '%"seeded":true%')
                ->delete();
        }

        $designer->notify(new OrderPlacedNotification(
            orderId: $order->id,
            customerName: $customer->name,
            portfolioTitle: $portfolio->title,
            totalPrice: (float) $order->total_price,
            orderType: $order->type,
            seeded: true,
        ));

        $customer->notify(new ProgressUpdatedNotification(
            orderId: $order->id,
            designerName: $designer->name,
            portfolioTitle: $portfolio->title,
            progress: 65,
            status: 'in_progress',
            seeded: true,
        ));

        $customer->notify(new NewMessageNotification(
            orderId: $order->id,
            senderName: $designer->name,
            senderRole: $designer->role,
            messagePreview: 'Halo, konsep awal landing page sudah saya siapkan.',
            seeded: true,
        ));

        $designer->notify(new RatingReceivedNotification(
            orderId: $order->id,
            reviewId: 0,
            customerName: $customer->name,
            rating: 5,
            comment: 'Komunikasinya cepat dan hasilnya rapi.',
            seeded: true,
        ));

        $designer->notifications()
            ->where('data', 'like', '%"rating_received"%')
            ->first()
            ?->markAsRead();
    }
}
