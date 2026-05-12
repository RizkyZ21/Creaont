@extends('admin.layouts.app')

@section('page-title', 'Reviews Management')

@section('content')
<div class="table-container">
    <div style="padding: 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
        <h5 style="margin: 0; color: var(--primary);">
            <i class="fas fa-star"></i> All Reviews
        </h5>
        <span class="badge bg-primary">Total: {{ $reviews->total() }}</span>
    </div>
    <table class="table">
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Designer</th>
                <th>Customer</th>
                <th>Rating</th>
                <th>Comment</th>
                <th>Date</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($reviews as $review)
                <tr>
                    <td><strong>#{{ $review->order_id }}</strong></td>
                    <td>{{ $review->designer->name }}</td>
                    <td>{{ $review->customer->name }}</td>
                    <td>
                        <div style="color: #f59e0b;">
                            @for ($i = 0; $i < $review->rating; $i++)
                                <i class="fas fa-star"></i>
                            @endfor
                            @for ($i = $review->rating; $i < 5; $i++)
                                <i class="far fa-star"></i>
                            @endfor
                            <span style="margin-left: 5px; color: #64748b;">{{ $review->rating }}/5</span>
                        </div>
                    </td>
                    <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis;">
                        {{ $review->comment ?? '-' }}
                    </td>
                    <td>{{ $review->created_at->format('d M Y') }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="6" class="text-center text-muted py-4">
                        No reviews found
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="d-flex justify-content-center mt-4">
    {{ $reviews->links() }}
</div>
@endsection
