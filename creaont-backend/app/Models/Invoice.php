<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    protected $fillable = [
        'order_id',
        'invoice_number',
        'amount',
        'status',
        'due_date',
        'paid_date',
        'notes',
    ];

    protected $casts = [
        'amount' => 'float',
        'due_date' => 'date',
        'paid_date' => 'date',
    ];

    public function order()
    {
        return $this->belongsTo(Orders::class);
    }
}
