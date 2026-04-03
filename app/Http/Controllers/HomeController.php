<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Portfolio;

class HomeController extends Controller
{

public function index()
{
    $portfolios = Portfolio::latest()->get();
    return view('home.index', compact('portfolios'));
}
}
