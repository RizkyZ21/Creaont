<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function messages($orderId)
    {
        return response()->json([
            [
                'id' => 1,
                'message' => 'Halo kak, desain sedang diproses',
                'sender' => 'designer',
                'order_id' => $orderId
            ]
        ]);
    }

    public function send(Request $request)
    {
        return response()->json([
            'message' => 'Chat sent',
            'data' => $request->all()
        ]);
    }
}