<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Revision extends Model
{
    protected $fillable = [
        'order_id',
        'revision_number',
        'notes',
        'status',
    ];

    public function order()
    {
        return $this->belongsTo(Orders::class);
    }
}
