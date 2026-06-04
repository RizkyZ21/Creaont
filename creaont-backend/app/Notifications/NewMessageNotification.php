<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class NewMessageNotification extends Notification
{
    use Queueable;

    public function __construct(
        public readonly int $orderId,
        public readonly string $senderName,
        public readonly string $senderRole,
        public readonly string $messagePreview,
        public readonly bool $seeded = false,
    ) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        $preview = mb_strlen($this->messagePreview) > 80
            ? mb_substr($this->messagePreview, 0, 80) . '...'
            : $this->messagePreview;

        return [
            'type' => 'new_message',
            'title' => 'Pesan Baru',
            'body' => "{$this->senderName}: {$preview}",
            'order_id' => $this->orderId,
            'sender_name' => $this->senderName,
            'sender_role' => $this->senderRole,
            'message_preview' => $preview,
            'seeded' => $this->seeded,
        ];
    }
}
