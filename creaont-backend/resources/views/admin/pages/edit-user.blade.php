@extends('admin.layouts.app')

@section('page-title', 'Edit User: ' . $user->name)

@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">User Information</h5>
            </div>
            <div style="padding: 20px;">
                <form action="{{ route('admin.update-user', $user->id) }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="mb-3">
                        <label class="form-label">Name</label>
                        <input type="text" name="name" class="form-control" value="{{ old('name', $user->name) }}" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" value="{{ old('email', $user->email) }}" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Role</label>
                        <select name="role" class="form-select" required>
                            <option value="">Select role</option>
                            <option value="customer" {{ $user->role === 'customer' ? 'selected' : '' }}>Customer</option>
                            <option value="designer" {{ $user->role === 'designer' ? 'selected' : '' }}>Designer</option>
                            <option value="admin" {{ $user->role === 'admin' ? 'selected' : '' }}>Admin</option>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                    <a href="{{ route('admin.users') }}" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Back
                    </a>
                </form>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">User Details</h5>
            </div>
            <div style="padding: 20px;">
                <div style="margin-bottom: 15px;">
                    <label class="text-muted">User ID:</label>
                    <p><strong>{{ $user->id }}</strong></p>
                </div>
                <div style="margin-bottom: 15px;">
                    <label class="text-muted">Joined:</label>
                    <p><strong>{{ $user->created_at->format('d M Y H:i') }}</strong></p>
                </div>
                <div style="margin-bottom: 15px;">
                    <label class="text-muted">Last Updated:</label>
                    <p><strong>{{ $user->updated_at->format('d M Y H:i') }}</strong></p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
