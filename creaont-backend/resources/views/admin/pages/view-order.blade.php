@extends('admin.layouts.app')

@section('page-title', 'Order #' . $order->id)

@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="table-container" style="margin-bottom: 20px;">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">Order Details</h5>
            </div>
            <div style="padding: 20px;">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="text-muted">Customer:</label>
                        <p><strong>{{ $order->customer->name }}</strong></p>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted">Designer:</label>
                        <p><strong>{{ $order->designer->name }}</strong></p>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="text-muted">Portfolio:</label>
                        <p><strong>{{ $order->portfolio->title }}</strong></p>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted">Status:</label>
                        <p>
                            <span class="badge bg-{{ 
                                $order->status === 'pending' ? 'warning' : 
                                ($order->status === 'in_progress' ? 'info' : 
                                ($order->status === 'completed' ? 'success' : 'danger'))
                            }}">
                                {{ ucfirst(str_replace('_', ' ', $order->status)) }}
                            </span>
                        </p>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-12">
                        <label class="text-muted">Progress:</label>
                        <div class="progress" style="height: 25px;">
                            <div class="progress-bar bg-success" role="progressbar" 
                                style="width: {{ $order->progress }}%;">
                                {{ $order->progress }}%
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="text-muted">Total Price:</label>
                        <p><strong>Rp {{ number_format($order->total_price, 0, ',', '.') }}</strong></p>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted">Deadline:</label>
                        <p><strong>{{ $order->deadline->format('d M Y') }}</strong></p>
                    </div>
                </div>
            </div>
        </div>

        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">Update Order Status</h5>
            </div>
            <div style="padding: 20px;">
                <form action="{{ route('admin.update-order-status', $order->id) }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="mb-3">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select" required>
                            <option value="">Select status</option>
                            <option value="pending" {{ $order->status === 'pending' ? 'selected' : '' }}>Pending</option>
                            <option value="in_progress" {{ $order->status === 'in_progress' ? 'selected' : '' }}>In Progress</option>
                            <option value="revision" {{ $order->status === 'revision' ? 'selected' : '' }}>Revision</option>
                            <option value="completed" {{ $order->status === 'completed' ? 'selected' : '' }}>Completed</option>
                            <option value="cancelled" {{ $order->status === 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Progress (%)</label>
                        <input type="number" name="progress" class="form-control" min="0" max="100" 
                            value="{{ $order->progress }}" required>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Update
                    </button>
                    <a href="{{ route('admin.orders') }}" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Back
                    </a>
                </form>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">Timeline</h5>
            </div>
            <div style="padding: 20px;">
                <div style="border-left: 3px solid var(--primary); padding-left: 15px;">
                    <div style="margin-bottom: 20px;">
                        <div style="color: var(--primary); font-weight: bold; font-size: 12px;">ORDER CREATED</div>
                        <div style="color: #64748b;">{{ $order->created_at->format('d M Y H:i') }}</div>
                    </div>
                    <div>
                        <div style="color: var(--primary); font-weight: bold; font-size: 12px;">LAST UPDATED</div>
                        <div style="color: #64748b;">{{ $order->updated_at->format('d M Y H:i') }}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
