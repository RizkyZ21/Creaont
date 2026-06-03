@extends('admin.layouts.app')

@section('page-title', 'Users Management')

@section('content')
<div class="table-container">
    <div style="padding: 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
        <h5 style="margin: 0; color: var(--primary);">
            <i class="fas fa-users"></i> All Users
        </h5>
        <div>
            <a href="{{ route('admin.create-user') }}" class="btn btn-sm btn-primary">
                <i class="fas fa-plus"></i> Add User
            </a>
            <span class="badge bg-primary">Total: {{ $users->total() }}</span>
        </div>
    </div>
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Joined</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($users as $user)
                <tr>
                    <td><strong>#{{ $user->id }}</strong></td>
                    <td>{{ $user->name }}</td>
                    <td>{{ $user->email }}</td>
                    <td>
                        <span class="badge bg-{{ 
                            $user->role === 'admin' ? 'danger' : 
                            ($user->role === 'designer' ? 'info' : 'success')
                        }}">
                            {{ ucfirst($user->role) }}
                        </span>
                    </td>
                    <td>{{ $user->created_at->format('d M Y') }}</td>
                    <td>
                        <a href="{{ route('admin.edit-user', $user->id) }}" class="btn btn-sm btn-warning btn-action">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                        <form action="{{ route('admin.delete-user', $user->id) }}" method="POST" style="display:inline;" 
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
                    <td colspan="6" class="text-center text-muted py-4">
                        No users found
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="d-flex justify-content-center mt-4">
    {{ $users->links() }}
</div>
@endsection
