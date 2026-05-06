<?php

namespace App\Http\Controllers;

use App\Models\Orders;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'customer') {
            $orders = Orders::with(['designer', 'portfolio'])
                ->where('customer_id', $user->id)
                ->latest()->get();
        } elseif ($user->role === 'designer') {
            $orders = Orders::with(['customer', 'portfolio'])
                ->where('designer_id', $user->id)
                ->latest()->get();
        } else {
            $orders = Orders::with(['customer', 'designer', 'portfolio'])
                ->latest()->get();
        }

        return response()->json(['success' => true, 'data' => $orders]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'designer_id'    => 'required|exists:users,id',
            'portfolio_id'   => 'required|exists:portfolios,id',
            'deadline'       => 'required|date|after:today',
            'estimated_days' => 'required|integer|min:1',
            'total_price'    => 'required|numeric|min:0',
        ]);

        $order = Orders::create([
            'customer_id'    => $request->user()->id,
            'designer_id'    => $request->designer_id,
            'portfolio_id'   => $request->portfolio_id,
            'status'         => 'pending',
            'progress'       => 0,
            'deadline'       => $request->deadline,
            'estimated_days' => $request->estimated_days,
            'total_price'    => $request->total_price,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Order berhasil dibuat',
            'data'    => $order->load(['customer', 'designer', 'portfolio']),
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $user  = $request->user();
        $order = Orders::with(['customer', 'designer', 'portfolio'])->findOrFail($id);

        if ($user->role !== 'admin'
            && $order->customer_id !== $user->id
            && $order->designer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        return response()->json(['success' => true, 'data' => $order]);
    }

    public function update(Request $request, $id)
    {
        $order = Orders::findOrFail($id);

        $request->validate([
            'status'   => 'sometimes|in:pending,in_progress,revision,completed,cancelled',
            'progress' => 'sometimes|integer|min:0|max:100',
        ]);

        $order->update($request->only('status', 'progress'));

        return response()->json([
            'success' => true,
            'message' => 'Order diperbarui',
            'data'    => $order->fresh(),
        ]);
    }
}