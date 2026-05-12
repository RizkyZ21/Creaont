<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('design_files', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->onDelete('cascade');
            $table->foreignId('designer_id')->constrained('users')->onDelete('cascade');
            $table->string('file_path');
            $table->string('file_name');
            $table->string('file_type'); // 'psd', 'ai', 'figma', etc
            $table->integer('file_size')->nullable(); // in bytes
            $table->string('version')->default('1.0');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('design_files');
    }
};
