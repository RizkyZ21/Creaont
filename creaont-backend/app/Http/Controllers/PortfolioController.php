<?php

namespace App\Http\Controllers;

use App\Models\Portfolio;
use Illuminate\Http\Request;

class PortfolioController extends Controller
{
    public function index()
    {
        return Portfolio::all();
    }

    public function store(Request $request)
    {
        return Portfolio::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $portfolio = Portfolio::findOrFail($id);
        $portfolio->update($request->all());
        return $portfolio;
    }

    public function destroy($id)
    {
        Portfolio::destroy($id);
        return response()->json(['message' => 'Deleted']);
    }
}
