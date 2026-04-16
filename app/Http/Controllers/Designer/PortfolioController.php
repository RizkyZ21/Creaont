<?php

namespace App\Http\Controllers\Designer;

use App\Http\Controllers\Controller;
use App\Models\Portfolio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PortfolioController extends Controller
{
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

        return redirect()->route('designer.dashboard')
            ->with('success', 'Portfolio berhasil ditambahkan');
    }

    public function edit($id)
    {
        $portfolio = Portfolio::findOrFail($id);

        if ($portfolio->user_id != auth()->id()) {
            abort(403);
        }

        return view('designer.portfolio.edit', compact('portfolio'));
    }

    public function update(Request $request, $id)
    {
        $portfolio = Portfolio::findOrFail($id);

        $data = $request->validate([
            'title' => 'required',
            'description' => 'nullable',
            'price' => 'nullable|numeric'
        ]);

        $portfolio->update($data);

        return redirect()->route('designer.dashboard')
            ->with('success', 'Updated');
    }

    public function destroy($id)
    {
        $portfolio = Portfolio::findOrFail($id);
        $portfolio->delete();

        return redirect()->route('designer.dashboard');
    }
}