<?php

namespace App\Services;

use App\Models\Orders;
use Illuminate\Support\Facades\Http;

class MidtransService
{
    public function createSnapToken(Orders $order): array
    {
        $serverKey = config('services.midtrans.server_key');
        if (!$serverKey) {
            return [
                'success' => false,
                'message' => 'MIDTRANS_SERVER_KEY belum dikonfigurasi',
            ];
        }

        $baseUrl = config('services.midtrans.is_production')
            ? 'https://app.midtrans.com'
            : 'https://app.sandbox.midtrans.com';

        $response = Http::withBasicAuth($serverKey, '')
            ->acceptJson()
            ->post("$baseUrl/snap/v1/transactions", [
                'transaction_details' => [
                    'order_id' => $order->payment_reference,
                    'gross_amount' => (int) round($order->total_price),
                ],
                'customer_details' => [
                    'first_name' => $order->customer?->name,
                    'email' => $order->customer?->email,
                ],
                'item_details' => [[
                    'id' => (string) ($order->portfolio_id ?? $order->id),
                    'price' => (int) round($order->total_price),
                    'quantity' => 1,
                    'name' => substr($order->portfolio?->title ?? "Order #{$order->id}", 0, 50),
                ]],
            ]);

        if (!$response->successful()) {
            return [
                'success' => false,
                'message' => $response->json('error_messages.0') ?? 'Gagal membuat transaksi Midtrans',
                'status' => $response->status(),
            ];
        }

        return [
            'success' => true,
            'token' => $response->json('token'),
            'redirect_url' => $response->json('redirect_url'),
        ];
    }
}
