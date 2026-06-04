<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class OrderPlacedNotification extends Notification
{
    use Queueable;

    public function __construct(
        public readonly int $orderId,
        public readonly string $customerName,
        public readonly string $portfolioTitle,
        public readonly float $totalPrice,
        public readonly string $orderType,
        public readonly bool $seeded = false,
    ) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        return [
            'type' => 'order_placed',
            'title' => 'Order Baru Masuk!',
            'body' => "{$this->customerName} memesan \"{$this->portfolioTitle}\"",
            'order_id' => $this->orderId,
            'customer_name' => $this->customerName,
            'portfolio_title' => $this->portfolioTitle,
            'total_price' => $this->totalPrice,
            'order_type' => $this->orderType,
            'seeded' => $this->seeded,
        ];
    }
}
