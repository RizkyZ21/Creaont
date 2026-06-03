<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Orders extends Model
{
    protected $fillable = [
        'customer_id',
        'designer_id',
        'portfolio_id',
        'description',
        'status',
        'type',
        'progress',
        'total_price',
        'deadline',
        'estimated_days',
        'payment_status',
        'payment_reference',
        'payment_token',
        'payment_url',
    ];

    protected $casts = [
        'total_price' => 'float',
        'progress'    => 'integer',
        'deadline'    => 'date',
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

    public function chats()
    {
        return $this->hasMany(Chat::class, 'order_id');
    }

    public function invoice()
    {
        return $this->hasOne(Invoice::class, 'order_id');
    }

    public function designFiles()
    {
        return $this->hasMany(DesignFile::class, 'order_id');
    }

    public function latestDesignFile()
    {
        return $this->hasOne(DesignFile::class, 'order_id')->latestOfMany();
    }
}
