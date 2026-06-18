<?php

namespace App\Http\Controllers;

use App\Services\DesignerRecommendationService;
use Illuminate\Http\Request;

class DesignerRecommendationController extends Controller
{
    public function index(Request $request, DesignerRecommendationService $service)
    {
        $criteria = $request->validate([
            'category'      => 'sometimes|nullable|string|max:100',
            'budget'        => 'sometimes|nullable|numeric|min:0',
            'deadline_days' => 'sometimes|nullable|integer|min:1|max:365',
            'brief'         => 'sometimes|nullable|string|max:1000',
            'limit'         => 'sometimes|nullable|integer|min:1|max:30',
        ]);

        return response()->json([
            'success' => true,
            'data'    => $service->recommend($criteria),
            'method'  => [
                'name'    => 'Weighted Scoring + Rule-Based Expert System',
                'weights' => [
                    'category'   => 25,
                    'budget'     => 20,
                    'rating'     => 20,
                    'experience' => 15,
                    'deadline'   => 12,
                    'keyword'    => 8,
                ],
                'total' => 100,
            ],
        ]);
    }
}
