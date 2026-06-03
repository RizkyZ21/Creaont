<?php

namespace App\Http\Controllers;

use App\Models\Orders;
use App\Services\MidtransService;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function snapToken(Request $request, MidtransService $midtrans)
    {
        $request->validate([
            'order_id' => 'required|exists:orders,id',
        ]);

        $order = Orders::with(['customer:id,name,email', 'portfolio:id,title'])
            ->findOrFail($request->order_id);

        if ($order->customer_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        if (!$order->payment_reference) {
            $order->payment_reference = 'CREAONT-' . $order->id . '-' . now()->format('YmdHis');
            $order->save();
        }

        if ($order->payment_token && $order->payment_url) {
            return response()->json([
                'success' => true,
                'token' => $order->payment_token,
                'redirect_url' => $order->payment_url,
                'payment_status' => $order->payment_status,
            ]);
        }

        $result = $midtrans->createSnapToken($order);
        if (($result['success'] ?? false) !== true) {
            return response()->json($result, 422);
        }

        $order->update([
            'payment_token' => $result['token'],
            'payment_url' => $result['redirect_url'],
            'payment_status' => 'pending',
        ]);

        return response()->json($result + ['payment_status' => 'pending']);
    }

    public function status(Request $request, int $orderId)
    {
        $order = Orders::findOrFail($orderId);
        if ($order->customer_id !== $request->user()->id
            && $order->designer_id !== $request->user()->id
            && $request->user()->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'success' => true,
            'payment_status' => $order->payment_status,
            'status' => $order->status,
            'payment_url' => $order->payment_url,
        ]);
    }

    public function notification(Request $request)
    {
        $serverKey = config('services.midtrans.server_key');
        $reference = $request->input('order_id');
        $statusCode = $request->input('status_code');
        $grossAmount = $request->input('gross_amount');
        $signature = $request->input('signature_key');

        if ($serverKey && $signature) {
            $expected = hash('sha512', $reference . $statusCode . $grossAmount . $serverKey);
            if (!hash_equals($expected, $signature)) {
                return response()->json(['success' => false, 'message' => 'Invalid signature'], 403);
            }
        }

        $order = Orders::where('payment_reference', $reference)->firstOrFail();
        $transactionStatus = $request->input('transaction_status');
        $fraudStatus = $request->input('fraud_status');

        $paid = in_array($transactionStatus, ['capture', 'settlement'], true)
            && ($fraudStatus === null || $fraudStatus === 'accept');
        $failed = in_array($transactionStatus, ['deny', 'expire', 'cancel'], true);

        if ($paid) {
            $order->payment_status = 'paid';
            if ($order->status === 'pending') {
                if ($order->type === 'service') {
                    $order->status = 'in_progress';
                } else {
                    $order->status = 'completed';
                    $order->progress = 100;
                }
            }
        } elseif ($failed) {
            $order->payment_status = 'failed';
        } else {
            $order->payment_status = 'pending';
        }

        $order->save();

        return response()->json(['success' => true]);
    }
}
