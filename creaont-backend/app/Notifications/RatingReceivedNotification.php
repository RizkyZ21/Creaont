<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class RatingReceivedNotification extends Notification
{
    use Queueable;

    public function __construct(
        public readonly int $orderId,
        public readonly int $reviewId,
        public readonly string $customerName,
        public readonly int $rating,
        public readonly string $comment,
        public readonly bool $seeded = false,
    ) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        return [
            'type' => 'rating_received',
            'title' => "Rating Baru {$this->rating}/5",
            'body' => "{$this->customerName} memberikan rating {$this->rating}/5"
                . ($this->comment ? ": \"{$this->comment}\"" : ''),
            'order_id' => $this->orderId,
            'review_id' => $this->reviewId,
            'customer_name' => $this->customerName,
            'rating' => $this->rating,
            'comment' => $this->comment,
            'seeded' => $this->seeded,
        ];
    }
}
