<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;

Route::get('/', function () {
    return view('welcome');
});

// Admin Routes
Route::prefix('admin')->group(function () {
    // Public admin login (will be added later)
    Route::get('/login', function () {
        return view('admin.pages.login');
    })->name('admin.login');

    // Protected admin routes
    Route::middleware(['auth', 'admin'])->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
        
        // Users
        Route::get('/users', [AdminController::class, 'users'])->name('admin.users');
        Route::get('/users/{id}/edit', [AdminController::class, 'editUser'])->name('admin.edit-user');
        Route::put('/users/{id}', [AdminController::class, 'updateUser'])->name('admin.update-user');
        Route::delete('/users/{id}', [AdminController::class, 'deleteUser'])->name('admin.delete-user');

        // Orders
        Route::get('/orders', [AdminController::class, 'orders'])->name('admin.orders');
        Route::get('/orders/{id}', [AdminController::class, 'viewOrder'])->name('admin.view-order');
        Route::put('/orders/{id}/status', [AdminController::class, 'updateOrderStatus'])->name('admin.update-order-status');

        // Portfolios
        Route::get('/portfolios', [AdminController::class, 'portfolios'])->name('admin.portfolios');
        Route::delete('/portfolios/{id}', [AdminController::class, 'deletePortfolio'])->name('admin.delete-portfolio');

        // Chats
        Route::get('/chats', [AdminController::class, 'chats'])->name('admin.chats');

        // Reviews
        Route::get('/reviews', [AdminController::class, 'reviews'])->name('admin.reviews');

        // Analytics
        Route::get('/analytics', [AdminController::class, 'analytics'])->name('admin.analytics');
    });
});
