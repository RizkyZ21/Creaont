<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use App\Models\Orders;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    // ── Ambil semua pesan dalam satu order ───────────────────────────
    public function messages(Request $request, $orderId)
    {
        $user  = $request->user();
        $order = Orders::findOrFail($orderId);

        // Hanya customer/designer yang terlibat, atau admin
        if ($user->role !== 'admin'
            && $order->customer_id !== $user->id
            && $order->designer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $messages = Chat::with('sender:id,name,role')
            ->where('order_id', $orderId)
            ->oldest()
            ->get();

        return response()->json(['success' => true, 'data' => $messages]);
    }

    // ── Kirim pesan baru ──────────────────────────────────────────────
    public function send(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'message'  => 'required|string|max:2000',
        ]);

        $order = Orders::findOrFail($request->order_id);

        if ($user->role !== 'admin'
            && $order->customer_id !== $user->id
            && $order->designer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $chat = Chat::create([
            'order_id'    => $request->order_id,
            'sender_id'   => $user->id,
            'message'     => $request->message,
            'sender_type' => $user->role, // 'customer', 'designer', or 'admin'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pesan terkirim',
            'data'    => $chat->load('sender:id,name,role'),
        ], 201);
    }
}
