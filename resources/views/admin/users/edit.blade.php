<h1>Edit Role</h1>

<form action="{{ url('/admin/users/' . $user->id) }}" method="POST">
    @csrf
    @method('PUT')

    <p>{{ $user->name }}</p>

    <select name="role">
        <option value="customer" {{ $user->role == 'customer' ? 'selected' : '' }}>Customer</option>
        <option value="designer" {{ $user->role == 'designer' ? 'selected' : '' }}>Designer</option>
        <option value="admin" {{ $user->role == 'admin' ? 'selected' : '' }}>Admin</option>
    </select>

    <button type="submit">Update</button>
</form>
