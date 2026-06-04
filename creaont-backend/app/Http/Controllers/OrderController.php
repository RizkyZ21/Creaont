<?php

namespace App\Http\Controllers;

use App\Models\Orders;
use App\Models\Portfolio;
use App\Models\DesignFile;
use App\Models\User;
use App\Notifications\OrderPlacedNotification;
use App\Notifications\ProgressUpdatedNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $user  = $request->user();
        $query = Orders::with([
            'customer:id,name',
            'designer:id,name',
            'portfolio:id,title,image,type,raw_file_name,raw_file_type',
            'latestDesignFile',
        ]);

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
        $order = Orders::with([
            'customer:id,name',
            'designer:id,name',
            'portfolio:id,title,image,category,type,raw_file_name,raw_file_type',
            'latestDesignFile',
        ])->findOrFail($id);

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

        if (!in_array($portfolio->type, ['design', 'service', 'product'], true)) {
            return response()->json([
                'success' => false,
                'message' => 'Tipe portfolio tidak valid',
            ], 422);
        }

        $type = $portfolio->type === 'product' ? 'design' : $portfolio->type;

        if ($type === 'service') {
            $request->validate([
                'deadline'       => 'required|date|after:today',
                'estimated_days' => 'required|integer|min:1',
            ]);
        }

        $order = Orders::create([
            'customer_id'    => $user->id,
            'designer_id'    => $portfolio->user_id,
            'portfolio_id'   => $portfolio->id,
            'description'    => $request->description ?? '',
            'status'         => 'pending',
            'type'           => $type,
            'progress'       => 0,
            'deadline'       => $type === 'service' ? $request->deadline : now()->toDateString(),
            'estimated_days' => $type === 'service' ? $request->estimated_days : 0,
            'total_price'    => $request->total_price,
            'payment_status' => 'pending',
        ]);

        $designer = User::find($portfolio->user_id);
        if ($designer) {
            $designer->notify(new OrderPlacedNotification(
                orderId: $order->id,
                customerName: $user->name,
                portfolioTitle: $portfolio->title,
                totalPrice: (float) $request->total_price,
                orderType: $type,
            ));
        }

        return response()->json([
            'success' => true,
            'message' => 'Order berhasil dibuat',
            'data'    => $order->load(['customer:id,name', 'designer:id,name', 'portfolio:id,title']),
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $user  = $request->user();
        $order = Orders::with(['portfolio:id,title'])->findOrFail($id);

        if ($user->role !== 'admin'
            && $order->customer_id !== $user->id
            && $order->designer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status'   => 'sometimes|in:pending,in_progress,revision,completed,cancelled',
            'progress' => 'sometimes|integer|min:0|max:100',
        ]);

        if ($request->input('status') === 'completed'
            && $order->type === 'service'
            && !$order->latestDesignFile()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Upload file hasil/raw dulu sebelum menyelesaikan order jasa.',
            ], 422);
        }

        if ($order->type === 'design' && in_array($request->input('status'), ['in_progress', 'revision'], true)) {
            return response()->json([
                'success' => false,
                'message' => 'Pembelian desain jadi tidak memakai proses pengerjaan.',
            ], 422);
        }

        if ($order->type === 'design'
            && $request->input('status') === 'completed'
            && $order->payment_status !== 'paid') {
            return response()->json([
                'success' => false,
                'message' => 'Desain jadi baru selesai setelah pembayaran berhasil.',
            ], 422);
        }

        $oldStatus = $order->status;
        $oldProgress = $order->progress;

        if ($request->has('status'))   $order->status   = $request->status;
        if ($request->has('progress')) $order->progress = $request->progress;
        $order->save();

        $statusChanged = $request->has('status') && $request->status !== $oldStatus;
        $progressChanged = $request->has('progress') && (int) $request->progress !== (int) $oldProgress;
        $isDesignerOrAdmin = $user->id === $order->designer_id || $user->role === 'admin';

        if ($isDesignerOrAdmin && ($statusChanged || $progressChanged)) {
            $customer = User::find($order->customer_id);
            if ($customer) {
                $customer->notify(new ProgressUpdatedNotification(
                    orderId: $order->id,
                    designerName: $user->name,
                    portfolioTitle: $order->portfolio?->title ?? 'Order #' . $order->id,
                    progress: (int) $order->progress,
                    status: $order->status,
                ));
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Order diperbarui',
            'data'    => $order->fresh()->load(['customer:id,name', 'designer:id,name', 'portfolio:id,title', 'latestDesignFile']),
        ]);
    }

    public function completeService(Request $request, $id)
    {
        $user = $request->user();
        $order = Orders::with(['portfolio:id,title'])->findOrFail($id);

        if ($order->designer_id !== $user->id && $user->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }
        if ($order->type !== 'service') {
            return response()->json(['success' => false, 'message' => 'Order ini bukan jasa'], 422);
        }

        $request->validate([
            'delivery_file' => 'required|file|max:102400',
        ]);

        $file = $request->file('delivery_file');
        $path = $file->store('orders/deliveries', 'local');

        $latestVersion = (int) DesignFile::where('order_id', $order->id)->count() + 1;
        DesignFile::create([
            'order_id' => $order->id,
            'designer_id' => $user->id,
            'file_path' => $path,
            'file_name' => $file->getClientOriginalName(),
            'file_type' => strtolower($file->getClientOriginalExtension()),
            'file_size' => $file->getSize(),
            'version' => (string) $latestVersion,
        ]);

        $order->status = 'completed';
        $order->progress = 100;
        $order->save();

        $customer = User::find($order->customer_id);
        if ($customer) {
            $customer->notify(new ProgressUpdatedNotification(
                orderId: $order->id,
                designerName: $user->name,
                portfolioTitle: $order->portfolio?->title ?? 'Order #' . $order->id,
                progress: 100,
                status: 'completed',
            ));
        }

        return response()->json([
            'success' => true,
            'message' => 'File hasil jasa berhasil diupload dan order selesai',
            'data' => $order->fresh()->load(['customer:id,name', 'designer:id,name', 'portfolio:id,title,type', 'latestDesignFile']),
        ]);
    }

    public function downloadDelivery(Request $request, $id)
    {
        $user = $request->user();
        $order = Orders::with('latestDesignFile')->findOrFail($id);

        // Hanya customer yang memesan atau admin yang boleh download
        if ($user->role !== 'admin' && $order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        // Order harus sudah selesai
        if ($order->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'File hanya bisa didownload setelah order selesai.',
            ], 422);
        }

        $file = $order->latestDesignFile;
        if (!$file || !Storage::disk('local')->exists($file->file_path)) {
            return response()->json(['success' => false, 'message' => 'File hasil belum tersedia'], 404);
        }

        return Storage::disk('local')->download($file->file_path, $file->file_name);
    }
}
