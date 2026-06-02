<?php

namespace App\Http\Controllers;

use App\Models\Orders;
use App\Models\Portfolio;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $user  = $request->user();
        $query = Orders::with(['customer:id,name', 'designer:id,name', 'portfolio:id,title,image,type']);

        if ($user->role === 'customer') {
            $query->where('customer_id', $user->id);
        } elseif ($user->role === 'designer') {
            // Designer bisa lihat order yang dia BUAT (sebagai customer) ATAU yang masuk ke dia
            $query->where(function ($q) use ($user) {
                $q->where('customer_id', $user->id)
                  ->orWhere('designer_id', $user->id);
            });
        }
        // admin: semua

        $orders = $query->latest()->get();
        return response()->json(['success' => true, 'data' => $orders]);
    }

    public function show(Request $request, $id)
    {
        $user  = $request->user();
        $order = Orders::with(['customer:id,name', 'designer:id,name', 'portfolio:id,title,image,category,type'])->findOrFail($id);

        if ($user->role !== 'admin'
            && $order->customer_id !== $user->id
            && $order->designer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        return response()->json(['success' => true, 'data' => $order]);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'portfolio_id'   => 'required|exists:portfolios,id',
            'deadline'       => 'required|date|after:today',
            'estimated_days' => 'required|integer|min:1',
            'total_price'    => 'required|numeric|min:0',
            'description'    => 'nullable|string',
        ]);

        $portfolio = Portfolio::findOrFail($request->portfolio_id);

        // Tidak bisa order portfolio sendiri
        if ($portfolio->user_id === $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak bisa memesan portfolio milik sendiri',
            ], 422);
        }

        // Hanya product yang bisa dipesan sekarang
        if ($portfolio->type !== 'product') {
            return response()->json([
                'success' => false,
                'message' => 'Pemesanan jasa belum tersedia',
            ], 422);
        }

        $order = Orders::create([
            'customer_id'    => $user->id,
            'designer_id'    => $portfolio->user_id,
            'portfolio_id'   => $portfolio->id,
            'description'    => $request->description ?? '',
            'status'         => 'pending',
            'type'           => 'product',
            'progress'       => 0,
            'deadline'       => $request->deadline,
            'estimated_days' => $request->estimated_days,
            'total_price'    => $request->total_price,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Order berhasil dibuat',
            'data'    => $order->load(['customer:id,name', 'designer:id,name', 'portfolio:id,title']),
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $user  = $request->user();
        $order = Orders::findOrFail($id);

        if ($user->role !== 'admin'
            && $order->customer_id !== $user->id
            && $order->designer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status'   => 'sometimes|in:pending,in_progress,revision,completed,cancelled',
            'progress' => 'sometimes|integer|min:0|max:100',
        ]);

        if ($request->has('status'))   $order->status   = $request->status;
        if ($request->has('progress')) $order->progress = $request->progress;
        $order->save();

        return response()->json([
            'success' => true,
            'message' => 'Order diperbarui',
            'data'    => $order->fresh()->load(['customer:id,name', 'designer:id,name', 'portfolio:id,title']),
        ]);
    }
}
