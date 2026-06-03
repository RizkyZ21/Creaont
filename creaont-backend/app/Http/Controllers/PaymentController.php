<?php

namespace App\Http\Controllers;

use App\Models\Orders;
use Illuminate\Http\Request;

/**
 * Payment dummy — tidak ada integrasi payment gateway sungguhan.
 * Saat user menekan tombol Bayar di Flutter, snapToken langsung
 * me-mark order sebagai paid (& completed untuk desain jadi).
 */
class PaymentController extends Controller
{
    /**
     * Dummy "snap token" — langsung tandai order PAID.
     * Untuk desain jadi (type=design): status → completed, progress = 100.
     * Untuk jasa (type=service): status → in_progress.
     */
    public function snapToken(Request $request)
    {
        $request->validate([
            'order_id' => 'required|exists:orders,id',
        ]);

        $order = Orders::with(['customer:id,name,email', 'portfolio:id,title'])
            ->findOrFail($request->order_id);

        if ($order->customer_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        // Tandai langsung PAID
        $order->payment_status = 'paid';

        if ($order->status === 'pending') {
            if ($order->type === 'design') {
                $order->status   = 'completed';
                $order->progress = 100;
            } else {
                // jasa: menunggu pengerjaan designer
                $order->status = 'in_progress';
            }
        }

        $order->save();

        return response()->json([
            'success'        => true,
            'payment_status' => 'paid',
            'status'         => $order->status,
            'message'        => 'Pembayaran berhasil',
        ]);
    }

    /**
     * Cek status pembayaran & order.
     */
    public function status(Request $request, int $orderId)
    {
        $order = Orders::findOrFail($orderId);

        if ($order->customer_id !== $request->user()->id
            && $order->designer_id !== $request->user()->id
            && $request->user()->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'success'        => true,
            'payment_status' => $order->payment_status,
            'status'         => $order->status,
        ]);
    }
}
