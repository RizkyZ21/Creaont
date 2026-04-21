<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index()
    {
        return response()->json([
            [
                'id' => 1,
                'title' => 'Logo Design',
                'price' => 350000,
                'status' => 'in progress'
            ]
        ]);
    }

    public function store(Request $request)
    {
        return response()->json([
            'message' => 'Order created successfully',
            'data' => $request->all()
        ]);
    }
}