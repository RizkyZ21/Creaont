@extends('admin.layouts.app')

@section('page-title', 'Categories Management')

@section('content')
<div class="table-container">
    <div style="padding: 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
        <h5 style="margin: 0; color: var(--primary);">
            <i class="fas fa-tags"></i> All Categories
        </h5>
        <div>
            <a href="{{ route('admin.create-category') }}" class="btn btn-sm btn-primary">
                <i class="fas fa-plus"></i> Add Category
            </a>
            <span class="badge bg-primary">Total: {{ $categories->total() }}</span>
        </div>
    </div>
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
                <th>Status</th>
                <th>Used</th>
                <th>Updated</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($categories as $category)
                <tr>
                    <td><strong>#{{ $category->id }}</strong></td>
                    <td>{{ $category->name }}</td>
                    <td>{{ $category->description ?? '-' }}</td>
                    <td>
                        <span class="badge bg-{{ $category->is_active ? 'success' : 'danger' }}">
                            {{ $category->is_active ? 'Active' : 'Inactive' }}
                        </span>
                    </td>
                    <td>{{ \App\Models\Portfolio::where('category', $category->name)->count() }}</td>
                    <td>{{ $category->updated_at->format('d M Y') }}</td>
                    <td>
                        <a href="{{ route('admin.edit-category', $category->id) }}" class="btn btn-sm btn-warning btn-action">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                        <form action="{{ route('admin.delete-category', $category->id) }}" method="POST" style="display:inline;"
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
                        No categories found
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="d-flex justify-content-center mt-4">
    {{ $categories->links() }}
</div>
@endsection
