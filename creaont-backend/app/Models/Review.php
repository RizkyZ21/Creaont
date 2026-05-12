<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = [
        'order_id',
        'designer_id',
        'customer_id',
        'rating',
        'comment',
    ];

    public function order()
    {
        return $this->belongsTo(Orders::class);
    }

    public function designer()
    {
        return $this->belongsTo(User::class);
    }

    public function customer()
    {
        return $this->belongsTo(User::class);
    }
}
