<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Creaont</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #6366f1;
            --secondary: #8b5cf6;
            --danger: #ef4444;
            --success: #10b981;
            --warning: #f59e0b;
        }

        body {
            background-color: #f8fafc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .sidebar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            min-height: 100vh;
            padding: 20px 0;
            position: fixed;
            left: 0;
            top: 0;
            width: 260px;
            color: white;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        .sidebar .logo {
            padding: 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 20px;
        }

        .sidebar .logo h5 {
            margin: 0;
            font-weight: bold;
        }

        .sidebar .nav-link {
            color: rgba(255, 255, 255, 0.8);
            padding: 12px 20px;
            border-left: 3px solid transparent;
            transition: all 0.3s ease;
        }

        .sidebar .nav-link:hover,
        .sidebar .nav-link.active {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
            border-left-color: white;
        }

        .sidebar .nav-link i {
            margin-right: 10px;
            width: 20px;
        }

        .main-content {
            margin-left: 260px;
            padding: 30px;
        }

        .topbar {
            background: white;
            padding: 15px 30px;
            border-radius: 8px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .topbar h1 {
            margin: 0;
            font-size: 24px;
            color: var(--primary);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border-left: 4px solid var(--primary);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        .stat-card.success {
            border-left-color: var(--success);
        }

        .stat-card.warning {
            border-left-color: var(--warning);
        }

        .stat-card.danger {
            border-left-color: var(--danger);
        }

        .stat-card-title {
            font-size: 14px;
            color: #64748b;
            margin-bottom: 5px;
        }

        .stat-card-value {
            font-size: 28px;
            font-weight: bold;
            color: var(--primary);
        }

        .table-container {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .table {
            margin: 0;
        }

        .table thead {
            background-color: #f1f5f9;
            border: none;
        }

        .table th {
            font-weight: 600;
            color: #475569;
            border: none;
            padding: 15px;
        }

        .table td {
            padding: 15px;
            border-bottom: 1px solid #e2e8f0;
        }

        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .btn-action {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 4px;
            margin: 0 2px;
        }

        .alert {
            border: none;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            
            .main-content {
                margin-left: 0;
            }
        }
    </style>
    @yield('extra-css')
</head>
<body>
    <div class="sidebar">
        <div class="logo">
            <h5><i class="fas fa-crown"></i> Creaont Admin</h5>
        </div>
        <nav class="nav flex-column">
            <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                <i class="fas fa-chart-line"></i> Dashboard
            </a>
            <a href="{{ route('admin.users') }}" class="nav-link {{ request()->routeIs('admin.users*') ? 'active' : '' }}">
                <i class="fas fa-users"></i> Users
            </a>
            <a href="{{ route('admin.orders') }}" class="nav-link {{ request()->routeIs('admin.orders*') ? 'active' : '' }}">
                <i class="fas fa-shopping-bag"></i> Orders
            </a>
            <a href="{{ route('admin.portfolios') }}" class="nav-link {{ request()->routeIs('admin.portfolios*') ? 'active' : '' }}">
                <i class="fas fa-image"></i> Portfolios
            </a>
            <a href="{{ route('admin.chats') }}" class="nav-link {{ request()->routeIs('admin.chats') ? 'active' : '' }}">
                <i class="fas fa-comments"></i> Chats
            </a>
            <a href="{{ route('admin.reviews') }}" class="nav-link {{ request()->routeIs('admin.reviews') ? 'active' : '' }}">
                <i class="fas fa-star"></i> Reviews
            </a>
            <a href="{{ route('admin.analytics') }}" class="nav-link {{ request()->routeIs('admin.analytics') ? 'active' : '' }}">
                <i class="fas fa-chart-pie"></i> Analytics
            </a>
            <hr style="background: rgba(255,255,255, 0.2); margin: 20px 0;">
            <a href="#" class="nav-link" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
            <form id="logout-form" action="/logout" method="POST" style="display: none;">
                @csrf
            </form>
        </nav>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h1>@yield('page-title', 'Dashboard')</h1>
            <div class="user-info">
                <span>{{ auth()->user()->name ?? 'Admin' }}</span>
                <div class="user-avatar">{{ substr(auth()->user()->name ?? 'A', 0, 1) }}</div>
            </div>
        </div>

        @if ($errors->any())
            <div class="alert alert-danger">
                <strong>Error!</strong>
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if (session('success'))
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> {{ session('success') }}
            </div>
        @endif

        @if (session('error'))
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> {{ session('error') }}
            </div>
        @endif

        @yield('content')
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    @yield('extra-js')
</body>
</html>
