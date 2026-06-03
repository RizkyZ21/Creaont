<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\Orders;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    // ── Kirim review setelah order completed ──────────────────────────
    public function store(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'rating'   => 'required|integer|min:1|max:5',
            'comment'  => 'nullable|string|max:1000',
        ]);

        $order = Orders::findOrFail($request->order_id);

        // Hanya customer yang terlibat di order ini
        if ($order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        // Hanya bisa review kalau order sudah completed
        if ($order->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Order belum selesai. Selesaikan order terlebih dahulu.',
            ], 422);
        }

        // Cek apakah sudah pernah review
        $existing = Review::where('order_id', $request->order_id)
            ->where('customer_id', $user->id)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah memberikan review untuk order ini.',
            ], 422);
        }

        $review = Review::create([
            'order_id'    => $request->order_id,
            'designer_id' => $order->designer_id,
            'customer_id' => $user->id,
            'rating'      => $request->rating,
            'comment'     => $request->comment ?? '',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil dikirim. Terima kasih!',
            'data'    => $review->load('customer:id,name'),
        ], 201);
    }

    // ── Ambil semua review milik satu portfolio ───────────────────────
    public function byPortfolio($portfolioId)
    {
        $reviews = Review::with('customer:id,name')
            ->whereHas('order', function ($q) use ($portfolioId) {
                $q->where('portfolio_id', $portfolioId);
            })
            ->latest()
            ->get();

        $avg = $reviews->avg('rating');

        return response()->json([
            'success'    => true,
            'data'       => $reviews,
            'avg_rating' => $avg ? round($avg, 1) : null,
            'total'      => $reviews->count(),
        ]);
    }

    // ── Cek apakah user sudah review order ini ────────────────────────
    public function check(Request $request, $orderId)
    {
        $existing = Review::where('order_id', $orderId)
            ->where('customer_id', $request->user()->id)
            ->first();

        return response()->json([
            'success'     => true,
            'has_reviewed' => $existing !== null,
            'review'      => $existing,
        ]);
    }
}
