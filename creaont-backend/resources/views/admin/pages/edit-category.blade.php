@extends('admin.layouts.app')

@section('page-title', 'Edit Category: ' . $category->name)

@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">Category Information</h5>
            </div>
            <div style="padding: 20px;">
                <form action="{{ route('admin.update-category', $category->id) }}" method="POST">
                    @csrf
                    @method('PUT')

                    <div class="mb-3">
                        <label class="form-label">Name</label>
                        <input type="text" name="name" class="form-control" value="{{ old('name', $category->name) }}" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea name="description" class="form-control" rows="4">{{ old('description', $category->description) }}</textarea>
                    </div>

                    <div class="form-check mb-3">
                        <input type="hidden" name="is_active" value="0">
                        <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" {{ old('is_active', $category->is_active) ? 'checked' : '' }}>
                        <label class="form-check-label" for="is_active">Active</label>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                    <a href="{{ route('admin.categories') }}" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Back
                    </a>
                </form>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">Category Details</h5>
            </div>
            <div style="padding: 20px;">
                <div style="margin-bottom: 15px;">
                    <label class="text-muted">Category ID:</label>
                    <p><strong>{{ $category->id }}</strong></p>
                </div>
                <div style="margin-bottom: 15px;">
                    <label class="text-muted">Used by Portfolios:</label>
                    <p><strong>{{ \App\Models\Portfolio::where('category', $category->name)->count() }}</strong></p>
                </div>
                <div style="margin-bottom: 15px;">
                    <label class="text-muted">Last Updated:</label>
                    <p><strong>{{ $category->updated_at->format('d M Y H:i') }}</strong></p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
