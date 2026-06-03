<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        $now = now();
        DB::table('categories')->insert([
            ['name' => 'UI/UX', 'description' => null, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'Logo', 'description' => null, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'Illustration', 'description' => null, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'Branding', 'description' => null, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'Motion', 'description' => null, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'Other', 'description' => null, 'is_active' => true, 'created_at' => $now, 'updated_at' => $now],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};
