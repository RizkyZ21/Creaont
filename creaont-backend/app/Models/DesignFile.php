<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DesignFile extends Model
{
    protected $fillable = [
        'order_id',
        'designer_id',
        'file_path',
        'file_name',
        'file_type',
        'file_size',
        'version',
    ];

    public function order()
    {
        return $this->belongsTo(Orders::class);
    }

    public function designer()
    {
        return $this->belongsTo(User::class);
    }
}
