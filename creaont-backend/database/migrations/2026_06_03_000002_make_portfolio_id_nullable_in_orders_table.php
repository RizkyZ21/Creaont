<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // Drop existing FK constraint first
            $table->dropForeign(['portfolio_id']);

            // Re-add as nullable with nullOnDelete
            $table->foreignId('portfolio_id')
                  ->nullable()
                  ->change();

            $table->foreign('portfolio_id')
                  ->references('id')
                  ->on('portfolios')
                  ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['portfolio_id']);

            $table->foreignId('portfolio_id')
                  ->nullable(false)
                  ->change();

            $table->foreign('portfolio_id')
                  ->references('id')
                  ->on('portfolios')
                  ->cascadeOnDelete();
        });
    }
};
