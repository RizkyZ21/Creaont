@extends('admin.layouts.app')

@section('page-title', 'Dashboard')

@section('content')
<div class="row mb-4">
    <div class="col-md-3">
        <div class="stat-card">
            <div class="stat-card-title">Total Users</div>
            <div class="stat-card-value">{{ $stats['total_users'] }}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card success">
            <div class="stat-card-title">Total Designers</div>
            <div class="stat-card-value">{{ $stats['total_designers'] }}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card warning">
            <div class="stat-card-title">Pending Orders</div>
            <div class="stat-card-value">{{ $stats['pending_orders'] }}</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card danger">
            <div class="stat-card-title">Total Revenue</div>
            <div class="stat-card-value">Rp {{ number_format($stats['total_revenue'], 0, ',', '.') }}</div>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-4">
        <div class="stat-card">
            <div class="stat-card-title">Total Orders</div>
            <div class="stat-card-value">{{ $stats['total_orders'] }}</div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="stat-card">
            <div class="stat-card-title">Total Portfolios</div>
            <div class="stat-card-value">{{ $stats['total_portfolios'] }}</div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="stat-card">
            <div class="stat-card-title">Total Categories</div>
            <div class="stat-card-value">{{ $stats['total_categories'] }}</div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-12">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">
                    <i class="fas fa-list"></i> Recent Orders
                </h5>
            </div>
            <table class="table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Preview</th>
                        <th>Customer</th>
                        <th>Designer</th>
                        <th>Status</th>
                        <th>Progress</th>
                        <th>Total Price</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($recent_orders as $order)
                        <tr>
                            <td><strong>#{{ $order->id }}</strong></td>
                            <td>
                                @if ($order->portfolio?->image)
                                    <img src="{{ asset('storage/' . ltrim(preg_replace('#^storage/#', '', $order->portfolio->image), '/')) }}"
                                        alt="{{ $order->portfolio->title ?? 'Portfolio preview' }}"
                                        style="width: 56px; height: 56px; object-fit: cover; border-radius: 8px; border: 1px solid var(--border);">
                                @else
                                    <div style="width: 56px; height: 56px; border-radius: 8px; border: 1px solid var(--border); display: flex; align-items: center; justify-content: center; color: var(--muted); background: var(--panel-soft);">
                                        <i class="fas fa-image"></i>
                                    </div>
                                @endif
                            </td>
                            <td>{{ $order->customer->name ?? 'N/A' }}</td>
                            <td>{{ $order->designer->name ?? 'N/A' }}</td>
                            <td>
                                <span class="badge bg-{{ 
                                    $order->status === 'pending' ? 'warning' : 
                                    ($order->status === 'in_progress' ? 'info' : 
                                    ($order->status === 'completed' ? 'success' : 'danger'))
                                }}">
                                    {{ ucfirst($order->status) }}
                                </span>
                            </td>
                            <td>
                                <div class="progress" style="height: 20px;">
                                    <div class="progress-bar bg-success" role="progressbar" 
                                        style="width: {{ $order->progress }}%;">
                                        {{ $order->progress }}%
                                    </div>
                                </div>
                            </td>
                            <td>Rp {{ number_format($order->total_price, 0, ',', '.') }}</td>
                            <td>
                                <a href="{{ route('admin.view-order', $order->id) }}" class="btn btn-sm btn-info btn-action">
                                    <i class="fas fa-eye"></i> View
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="text-center text-muted py-4">
                                No orders yet
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
