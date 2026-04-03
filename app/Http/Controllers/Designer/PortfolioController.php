<?php

namespace App\Http\Controllers\Designer;

use App\Http\Controllers\Controller;
use App\Models\Portfolio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PortfolioController extends Controller
{
    public function index()
    {
        $portfolios = Auth::user()->portfolios;
        return view('designer.portfolio.index', compact('portfolios'));
    }

    public function create()
    {
        return view('designer.portfolio.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required',
            'description' => 'nullable',
            'image' => 'nullable|image',
            'price' => 'nullable|numeric'
        ]);

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('portfolio', 'public');
        }

        $data['user_id'] = Auth::id();

        Portfolio::create($data);

        return redirect('/portfolio')->with('success', 'Portfolio berhasil ditambahkan');
    }

    public function edit(Portfolio $portfolio)
    {
        return view('designer.portfolio.edit', compact('portfolio'));
    }

    public function update(Request $request, Portfolio $portfolio)
    {
        $data = $request->validate([
            'title' => 'required',
            'description' => 'nullable',
            'price' => 'nullable|numeric'
        ]);

        $portfolio->update($data);

        return redirect('/portfolio')->with('success', 'Updated');
    }

    public function destroy(Portfolio $portfolio)
    {
        $portfolio->delete();
        return back();
    }
}