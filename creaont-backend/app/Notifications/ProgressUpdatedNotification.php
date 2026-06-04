<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class ProgressUpdatedNotification extends Notification
{
    use Queueable;

    public function __construct(
        public readonly int $orderId,
        public readonly string $designerName,
        public readonly string $portfolioTitle,
        public readonly int $progress,
        public readonly string $status,
        public readonly bool $seeded = false,
    ) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        $statusLabel = match ($this->status) {
            'in_progress' => 'Sedang dikerjakan',
            'revision' => 'Dalam revisi',
            'completed' => 'Selesai',
            'cancelled' => 'Dibatalkan',
            default => ucfirst($this->status),
        };

        return [
            'type' => 'progress_updated',
            'title' => 'Update Progres Order',
            'body' => "{$this->designerName} mengupdate order \"{$this->portfolioTitle}\" - {$statusLabel} ({$this->progress}%)",
            'order_id' => $this->orderId,
            'designer_name' => $this->designerName,
            'portfolio_title' => $this->portfolioTitle,
            'progress' => $this->progress,
            'status' => $this->status,
            'status_label' => $statusLabel,
            'seeded' => $this->seeded,
        ];
    }
}
