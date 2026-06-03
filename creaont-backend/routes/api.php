<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\PortfolioController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\PaymentController;

// ── Public ───────────────────────────────────────────────────────────
Route::post('/login',    [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::get('/portfolios',                       [PortfolioController::class, 'index']);
Route::get('/portfolios/popular',               [PortfolioController::class, 'popular']);
Route::get('/services',                         [PortfolioController::class, 'services']);
Route::get('/portfolios/designer/{designerId}', [PortfolioController::class, 'byDesigner']);

// ── Protected ────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout',         [AuthController::class, 'logout']);
    Route::get('/me',              [AuthController::class, 'me']);
    Route::post('/update-profile', [AuthController::class, 'updateProfile']);
    Route::post('/upgrade-to-designer', [AuthController::class, 'upgradeToDesigner']);

    Route::get('/orders',      [OrderController::class, 'index']);
    Route::post('/orders',     [OrderController::class, 'store']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);
    Route::put('/orders/{id}', [OrderController::class, 'update']);
    Route::post('/orders/{id}/complete-service', [OrderController::class, 'completeService']);
    Route::get('/orders/{id}/delivery/download', [OrderController::class, 'downloadDelivery']);

    Route::post('/payments/snap-token', [PaymentController::class, 'snapToken']);
    Route::get('/payments/{orderId}/status', [PaymentController::class, 'status']);
    Route::post('/payments/notification', [PaymentController::class, 'notification'])->withoutMiddleware('auth:sanctum');

    Route::get('/my-portfolios',            [PortfolioController::class, 'myPortfolios']);
    Route::post('/portfolios',              [PortfolioController::class, 'store']);
    Route::post('/portfolios/{id}',         [PortfolioController::class, 'update']);
    Route::delete('/portfolios/{id}',       [PortfolioController::class, 'destroy']);
    Route::get('/portfolios/{id}/download', [PortfolioController::class, 'download']);

    Route::get('/chat/{orderId}',  [ChatController::class, 'messages']);
    Route::post('/chat/send',      [ChatController::class, 'send']);

    Route::get('/admin/summary',   [AdminController::class, 'summary']);
});
