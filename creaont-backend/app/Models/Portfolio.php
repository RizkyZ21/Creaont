<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Portfolio extends Model
{
    protected $fillable = [
        'user_id',
        'title',
        'description',
        'category',
        'type',
        'price',
        'image',
        'raw_file',
        'raw_file_name',
        'raw_file_type',
    ];

    protected $casts = [
        'price' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orders()
    {
        return $this->hasMany(Orders::class);
    }

    public function isBoughtBy(int $userId): bool
    {
        return $this->orders()
            ->where('customer_id', $userId)
            ->where('payment_status', 'paid')
            ->exists();
    }
}
