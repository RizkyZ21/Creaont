<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Orders extends Model
{
    protected $fillable = [
        'customer_id',
        'designer_id',
        'portfolio_id',
        'status',
        'progress',
        'deadline',
        'estimated_days',
        'total_price',
    ];

    protected $casts = [
        'deadline'    => 'date',
        'total_price' => 'float',
        'progress'    => 'integer',
    ];

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function designer()
    {
        return $this->belongsTo(User::class, 'designer_id');
    }

    public function portfolio()
    {
        return $this->belongsTo(Portfolio::class);
    }
}