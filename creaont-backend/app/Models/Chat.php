<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Chat extends Model
{
    protected $fillable = [
        'order_id',
        'sender_id',
        'message',
        'sender_type',
    ];

    public function order()
    {
        return $this->belongsTo(Orders::class);
    }

    public function sender()
    {
        return $this->belongsTo(User::class);
    }
}
