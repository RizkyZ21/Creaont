<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Creaont</title>
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
            --danger: #fb7185;
            --success: #34d399;
        }

        body {
            background: var(--bg);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: var(--text);
            padding: 20px;
        }

        .login-container {
            width: 100%;
            max-width: 400px;
            background: var(--panel);
            padding: 40px;
            border-radius: 8px;
            border: 1px solid var(--border);
        }

        .login-logo {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-logo i {
            font-size: 48px;
            color: var(--primary);
        }

        .login-logo h3 {
            color: var(--text);
            margin-top: 10px;
            margin: 0;
        }

        .form-control {
            padding: 12px 15px;
            border-radius: 8px;
            border: 1px solid var(--border);
            background-color: var(--panel-soft);
            color: var(--text);
        }

        .form-control:focus {
            border-color: var(--primary);
            background-color: var(--panel-soft);
            color: var(--text);
            box-shadow: 0 0 0 0.2rem rgba(56, 189, 248, 0.16);
        }

        .form-label,
        .form-check-label {
            color: var(--muted);
        }

        .btn-login {
            padding: 12px;
            border-radius: 8px;
            font-weight: 600;
            background: var(--primary);
            border: 1px solid var(--primary);
            width: 100%;
            color: #082f49;
        }

        .btn-login:hover {
            background: #7dd3fc;
            border-color: #7dd3fc;
            color: #082f49;
        }

        .login-footer {
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: var(--muted);
        }

        .alert {
            border: none;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .alert-danger {
            background-color: rgba(251, 113, 133, 0.16);
            color: #fecdd3;
        }

        .alert-success {
            background-color: rgba(52, 211, 153, 0.16);
            color: #bbf7d0;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-logo">
            <i class="fas fa-crown"></i>
            <h3>Creaont Admin</h3>
        </div>

        @if (session('error'))
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> {{ session('error') }}
            </div>
        @endif

        @if (session('success'))
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> {{ session('success') }}
            </div>
        @endif

        <p style="text-align: center; color: var(--muted); margin-bottom: 25px;">
            Sign in with your admin credentials
        </p>

        <form action="{{ route('admin.login.submit') }}" method="POST">
            @csrf
            
            <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email" name="email" class="form-control" placeholder="admin@example.com" required autofocus>
            </div>

            <div class="mb-3">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" placeholder="Password" required>
            </div>

            <div class="mb-3 form-check">
                <input type="checkbox" class="form-check-input" id="remember" name="remember">
                <label class="form-check-label" for="remember">
                    Remember me
                </label>
            </div>

            <button type="submit" class="btn btn-login btn-primary">
                <i class="fas fa-sign-in-alt"></i> Login
            </button>
        </form>

        <div class="login-footer">
            <p style="margin: 0;">
                Need help? Contact administrator
            </p>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
