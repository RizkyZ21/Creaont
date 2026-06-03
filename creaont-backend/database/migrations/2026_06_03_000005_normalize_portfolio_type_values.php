<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('portfolios', 'type')) {
            DB::table('portfolios')->where('type', 'product')->update(['type' => 'design']);
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('portfolios', 'type')) {
            DB::table('portfolios')->where('type', 'design')->update(['type' => 'product']);
        }
    }
};
