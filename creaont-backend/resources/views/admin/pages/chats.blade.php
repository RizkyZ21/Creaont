@extends('admin.layouts.app')

@section('page-title', 'Chats Monitoring')

@section('content')
<div class="table-container">
    <div style="padding: 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
        <h5 style="margin: 0; color: var(--primary);">
            <i class="fas fa-comments"></i> Recent Chats
        </h5>
        <span class="badge bg-primary">Total: {{ $chats->total() }}</span>
    </div>
    <table class="table">
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Sender</th>
                <th>Type</th>
                <th>Message</th>
                <th>Sent At</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($chats as $chat)
                <tr>
                    <td><strong>#{{ $chat->order_id }}</strong></td>
                    <td>{{ $chat->sender->name }}</td>
                    <td>
                        <span class="badge bg-{{ $chat->sender_type === 'designer' ? 'info' : 'success' }}">
                            {{ ucfirst($chat->sender_type) }}
                        </span>
                    </td>
                    <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis;">
                        {{ Str::limit($chat->message, 60) }}
                    </td>
                    <td>{{ $chat->created_at->format('d M Y H:i') }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="5" class="text-center text-muted py-4">
                        No chats found
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="d-flex justify-content-center mt-4">
    {{ $chats->links() }}
</div>
@endsection
