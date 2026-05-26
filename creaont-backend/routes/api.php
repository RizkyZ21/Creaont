<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\PortfolioController;
use App\Http\Controllers\AdminController;

Route::post('/login',    [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::get('/portfolios', [PortfolioController::class, 'index']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout',         [AuthController::class, 'logout']);
    Route::get('/me',              [AuthController::class, 'me']);
    Route::post('/update-profile', [AuthController::class, 'updateProfile']);

    Route::get('/orders',      [OrderController::class, 'index']);
    Route::post('/orders',     [OrderController::class, 'store']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);
    Route::put('/orders/{id}', [OrderController::class, 'update']);

    Route::post('/portfolios',        [PortfolioController::class, 'store']);
    Route::put('/portfolios/{id}',    [PortfolioController::class, 'update']);
    Route::delete('/portfolios/{id}', [PortfolioController::class, 'destroy']);

    Route::get('/chat/{orderId}', [ChatController::class, 'messages']);
    Route::post('/chat/send',     [ChatController::class, 'send']);

    Route::get('/admin/summary', [AdminController::class, 'summary']);
});
