@extends('admin.layouts.app')

@section('page-title', 'Portfolios Management')

@section('content')
<div class="table-container">
    <div style="padding: 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
        <h5 style="margin: 0; color: var(--primary);">
            <i class="fas fa-image"></i> All Portfolios
        </h5>
        <span class="badge bg-primary">Total: {{ $portfolios->total() }}</span>
    </div>
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Designer</th>
                <th>Category</th>
                <th>Price</th>
                <th>Created</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($portfolios as $portfolio)
                <tr>
                    <td><strong>#{{ $portfolio->id }}</strong></td>
                    <td>{{ $portfolio->title }}</td>
                    <td>{{ $portfolio->user->name }}</td>
                    <td>{{ $portfolio->category }}</td>
                    <td>Rp {{ number_format($portfolio->price, 0, ',', '.') }}</td>
                    <td>{{ $portfolio->created_at->format('d M Y') }}</td>
                    <td>
                        <form action="{{ route('admin.delete-portfolio', $portfolio->id) }}" method="POST" style="display:inline;" 
                              onsubmit="return confirm('Are you sure?');">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-sm btn-danger btn-action">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" class="text-center text-muted py-4">
                        No portfolios found
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="d-flex justify-content-center mt-4">
    {{ $portfolios->links() }}
</div>
@endsection
