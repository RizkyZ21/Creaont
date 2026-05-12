@extends('admin.layouts.app')

@section('page-title', 'Orders Management')

@section('content')
<div class="table-container">
    <div style="padding: 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
        <h5 style="margin: 0; color: var(--primary);">
            <i class="fas fa-shopping-bag"></i> All Orders
        </h5>
        <span class="badge bg-primary">Total: {{ $orders->total() }}</span>
    </div>
    <table class="table">
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Designer</th>
                <th>Portfolio</th>
                <th>Status</th>
                <th>Progress</th>
                <th>Total Price</th>
                <th>Deadline</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($orders as $order)
                <tr>
                    <td><strong>#{{ $order->id }}</strong></td>
                    <td>{{ $order->customer->name ?? 'N/A' }}</td>
                    <td>{{ $order->designer->name ?? 'N/A' }}</td>
                    <td>{{ $order->portfolio->title ?? 'N/A' }}</td>
                    <td>
                        <span class="badge bg-{{ 
                            $order->status === 'pending' ? 'warning' : 
                            ($order->status === 'in_progress' ? 'info' : 
                            ($order->status === 'completed' ? 'success' : 'danger'))
                        }}">
                            {{ ucfirst(str_replace('_', ' ', $order->status)) }}
                        </span>
                    </td>
                    <td>
                        <div class="progress" style="height: 20px; width: 100px;">
                            <div class="progress-bar bg-success" role="progressbar" 
                                style="width: {{ $order->progress }}%;">
                                {{ $order->progress }}%
                            </div>
                        </div>
                    </td>
                    <td><strong>Rp {{ number_format($order->total_price, 0, ',', '.') }}</strong></td>
                    <td>{{ $order->deadline->format('d M Y') }}</td>
                    <td>
                        <a href="{{ route('admin.view-order', $order->id) }}" class="btn btn-sm btn-info btn-action">
                            <i class="fas fa-eye"></i> View
                        </a>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="9" class="text-center text-muted py-4">
                        No orders found
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="d-flex justify-content-center mt-4">
    {{ $orders->links() }}
</div>
@endsection
