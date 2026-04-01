<?php

Route::get('/', [HomeController::class, 'index']);

Route::middleware(['auth'])->group(function () {

    Route::get('/profile', function () {
        return view('profile.index');
    });

    // Designer
    Route::middleware(['role:designer'])->group(function () {
        Route::get('/designer/dashboard', function () {
            return view('designer.dashboard');
        });

        Route::resource('/portfolio', PortfolioController::class);
    });

    // Admin
    Route::middleware(['role:admin'])->group(function () {
        Route::get('/admin/dashboard', [DashboardController::class, 'index']);
        Route::resource('/admin/users', UserController::class);
    });
});
