<?php

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Designer\PortfolioController;
use App\Models\Portfolio;

/*
|--------------------------------------------------------------------------
| AUTH
|--------------------------------------------------------------------------
*/

// LOGIN
Route::get('/login', [AuthController::class, 'loginForm']);
Route::post('/login', [AuthController::class, 'login']);

// REGISTER
Route::get('/register', [AuthController::class, 'registerForm']);
Route::post('/register', [AuthController::class, 'register']);

// LOGOUT
Route::post('/logout', [AuthController::class, 'logout']);


/*
|--------------------------------------------------------------------------
| LANDING
|--------------------------------------------------------------------------
*/
Route::get('/', function () {
    $portfolios = Portfolio::latest()->take(8)->get();
    return view('landing', compact('portfolios'));
});


/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (LOGIN WAJIB)
|--------------------------------------------------------------------------
*/
Route::middleware('auth')->group(function () {

    // DASHBOARD
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

    Route::get('/designer/dashboard', function () {
        if (Auth::user()->role != 'designer') abort(403);
        return view('designer.dashboard');
    })->name('designer.dashboard');

    // PROFILE
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // ADMIN
    Route::resource('/admin/users', UserController::class);

    // 🔥 DESIGNER PORTFOLIO (FULL CRUD)
    Route::resource('/designer/portfolio', PortfolioController::class);
});
