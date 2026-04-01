<?php
public function portfolios()
{
    return $this->hasMany(Portfolio::class);
}