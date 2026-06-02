<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('portfolios', function (Blueprint $table) {
            $table->string('raw_file')->nullable()->after('image');       // path file asli (.cdr, .psd, .ai, dll)
            $table->string('raw_file_name')->nullable()->after('raw_file'); // nama asli file
            $table->string('raw_file_type')->nullable()->after('raw_file_name'); // ekstensi
        });
    }

    public function down(): void
    {
        Schema::table('portfolios', function (Blueprint $table) {
            $table->dropColumn(['raw_file', 'raw_file_name', 'raw_file_type']);
        });
    }
};
