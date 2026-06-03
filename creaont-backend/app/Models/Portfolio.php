<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Portfolio extends Model
{
    protected $fillable = [
        'user_id', 'title', 'description', 'category', 'type',
        'price', 'image', 'raw_file', 'raw_file_name', 'raw_file_type',
    ];

    protected $casts = ['price' => 'float'];

    // Append image_url ke setiap response JSON
    protected $appends = ['image_url'];

    public function getImageUrlAttribute(): ?string
    {
        if (!$this->image) return null;
        // Jika sudah full URL, langsung return
        if (str_starts_with($this->image, 'http')) return $this->image;
        // Build URL dari storage public disk
        return Storage::disk('public')->url($this->image);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orders()
    {
        return $this->hasMany(Orders::class);
    }

    public function reviews()
    {
        return $this->hasManyThrough(
            Review::class,
            Orders::class,
            'portfolio_id',
            'order_id',
            'id',
            'id'
        );
    }

    public function isBoughtBy(int $userId): bool
    {
        return $this->orders()
            ->where('customer_id', $userId)
            ->where('payment_status', 'paid')
            ->exists();
    }
}
