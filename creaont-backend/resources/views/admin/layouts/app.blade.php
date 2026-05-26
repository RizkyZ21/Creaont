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
            --bg: #101827;
            --panel: #162033;
            --panel-soft: #1d2940;
            --border: #263247;
            --text: #f8fafc;
            --muted: #94a3b8;
            --primary: #38bdf8;
            --secondary: #a78bfa;
            --danger: #fb7185;
            --success: #34d399;
            --warning: #fbbf24;
            --info: #60a5fa;
        }

        body {
            background-color: var(--bg);
            color: var(--text);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .sidebar {
            background: #0f172a;
            min-height: 100vh;
            padding: 20px 0;
            position: fixed;
            left: 0;
            top: 0;
            width: 260px;
            color: var(--text);
            border-right: 1px solid var(--border);
        }

        .sidebar .logo {
            padding: 20px;
            border-bottom: 1px solid var(--border);
            margin-bottom: 20px;
        }

        .sidebar .logo h5 {
            margin: 0;
            font-weight: bold;
            color: var(--text);
        }

        .sidebar .nav-link {
            color: var(--muted);
            padding: 12px 20px;
            border-left: 3px solid transparent;
            transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
        }

        .sidebar .nav-link:hover,
        .sidebar .nav-link.active {
            background-color: var(--panel);
            color: var(--text);
            border-left-color: var(--primary);
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
            background: var(--panel);
            padding: 15px 30px;
            border-radius: 8px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 1px solid var(--border);
        }

        .topbar h1 {
            margin: 0;
            font-size: 24px;
            color: var(--text);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
            color: var(--muted);
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(56, 189, 248, 0.16);
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        .stat-card {
            background: var(--panel);
            padding: 20px;
            border-radius: 8px;
            border: 1px solid var(--border);
            border-left: 4px solid var(--primary);
            min-height: 118px;
            transition: border-color 0.2s ease, transform 0.2s ease;
        }

        .stat-card:hover {
            transform: translateY(-2px);
            border-color: rgba(56, 189, 248, 0.45);
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
            color: var(--muted);
            margin-bottom: 5px;
        }

        .stat-card-value {
            font-size: 28px;
            font-weight: bold;
            color: var(--text);
            word-break: break-word;
        }

        .table-container {
            background: var(--panel);
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid var(--border);
        }

        .table-container > div {
            border-bottom-color: var(--border) !important;
        }

        .table {
            margin: 0;
            --bs-table-bg: transparent;
            --bs-table-color: var(--text);
            --bs-table-border-color: var(--border);
            --bs-table-hover-bg: var(--panel-soft);
            color: var(--text);
        }

        .table thead {
            background-color: var(--panel-soft);
            border: none;
        }

        .table th {
            font-weight: 600;
            color: var(--muted);
            border: none;
            padding: 15px;
        }

        .table td {
            padding: 15px;
            border-bottom: 1px solid var(--border);
            color: var(--text);
            vertical-align: middle;
        }

        .text-muted {
            color: var(--muted) !important;
        }

        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .bg-primary,
        .btn-primary {
            background-color: var(--primary) !important;
            border-color: var(--primary) !important;
            color: #082f49 !important;
        }

        .bg-info,
        .btn-info {
            background-color: var(--info) !important;
            border-color: var(--info) !important;
            color: #0f172a !important;
        }

        .bg-success,
        .btn-success {
            background-color: var(--success) !important;
            border-color: var(--success) !important;
            color: #052e1d !important;
        }

        .bg-warning,
        .btn-warning {
            background-color: var(--warning) !important;
            border-color: var(--warning) !important;
            color: #422006 !important;
        }

        .bg-danger,
        .btn-danger {
            background-color: var(--danger) !important;
            border-color: var(--danger) !important;
            color: #450a0a !important;
        }

        .btn-secondary {
            background-color: var(--panel-soft);
            border-color: var(--border);
            color: var(--text);
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

        .alert-success {
            background-color: rgba(52, 211, 153, 0.16);
            color: #bbf7d0;
        }

        .alert-danger {
            background-color: rgba(251, 113, 133, 0.16);
            color: #fecdd3;
        }

        .form-control,
        .form-select {
            background-color: var(--panel-soft);
            border: 1px solid var(--border);
            border-radius: 8px;
            color: var(--text);
        }

        .form-control:focus,
        .form-select:focus {
            background-color: var(--panel-soft);
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(56, 189, 248, 0.16);
            color: var(--text);
        }

        .form-label {
            color: var(--muted);
        }

        .progress {
            background-color: var(--border);
            border-radius: 999px;
        }

        .pagination .page-link {
            background-color: var(--panel);
            border-color: var(--border);
            color: var(--muted);
        }

        .pagination .active .page-link {
            background-color: var(--primary);
            border-color: var(--primary);
            color: #082f49;
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
            <form id="logout-form" action="{{ route('admin.logout') }}" method="POST" style="display: none;">
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
