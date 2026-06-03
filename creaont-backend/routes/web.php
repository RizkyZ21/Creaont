<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/login', function () {
    return redirect()->route('admin.login');
})->name('login');

// Admin Routes
Route::prefix('admin')->group(function () {
    Route::get('/login', function () {
        return view('admin.pages.login');
    })->name('admin.login');
    Route::post('/login', [AdminController::class, 'login'])->name('admin.login.submit');

    // Protected admin routes
    Route::middleware(['auth', 'admin'])->group(function () {
        Route::post('/logout', [AdminController::class, 'logout'])->name('admin.logout');
        Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
        
        // Users
        Route::get('/users', [AdminController::class, 'users'])->name('admin.users');
        Route::get('/users/create', [AdminController::class, 'createUser'])->name('admin.create-user');
        Route::post('/users', [AdminController::class, 'storeUser'])->name('admin.store-user');
        Route::get('/users/{id}/edit', [AdminController::class, 'editUser'])->name('admin.edit-user');
        Route::put('/users/{id}', [AdminController::class, 'updateUser'])->name('admin.update-user');
        Route::delete('/users/{id}', [AdminController::class, 'deleteUser'])->name('admin.delete-user');

        // Categories
        Route::get('/categories', [AdminController::class, 'categories'])->name('admin.categories');
        Route::get('/categories/create', [AdminController::class, 'createCategory'])->name('admin.create-category');
        Route::post('/categories', [AdminController::class, 'storeCategory'])->name('admin.store-category');
        Route::get('/categories/{id}/edit', [AdminController::class, 'editCategory'])->name('admin.edit-category');
        Route::put('/categories/{id}', [AdminController::class, 'updateCategory'])->name('admin.update-category');
        Route::delete('/categories/{id}', [AdminController::class, 'deleteCategory'])->name('admin.delete-category');

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
