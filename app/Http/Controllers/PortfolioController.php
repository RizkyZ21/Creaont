<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Portfolio;

class PortfolioController extends Controller
{
    // FORM CREATE
    public function create()
    {
        return view('designer.portfolio.create');
    }

    // SIMPAN DATA
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required',
            'price' => 'required|numeric',
            'description' => 'required',
        ]);

        Portfolio::create([
            'user_id' => auth()->id(),
            'title' => $request->title,
            'price' => $request->price,
            'description' => $request->description,
        ]);

        return redirect('/designer/dashboard');
    }

    // FORM EDIT
    public function edit($id)
    {
        $portfolio = Portfolio::findOrFail($id);

        if ($portfolio->user_id != auth()->id()) {
            abort(403);
        }

        return view('designer.portfolio.edit', compact('portfolio'));
    }

    // UPDATE
    public function update(Request $request, $id)
    {
        $portfolio = Portfolio::findOrFail($id);

        if ($portfolio->user_id != auth()->id()) {
            abort(403);
        }

        $portfolio->update([
            'title' => $request->title,
            'price' => $request->price,
            'description' => $request->description,
        ]);

        return redirect('/designer/dashboard');
    }
}