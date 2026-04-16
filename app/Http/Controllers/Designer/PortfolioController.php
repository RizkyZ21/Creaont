<?php

namespace App\Http\Controllers\Designer;

use App\Http\Controllers\Controller;
use App\Models\Portfolio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class PortfolioController extends Controller
{
    public function index()
    {
        $portfolios = Auth::user()->portfolios;
        return view('designer.portofolio.index', compact('portfolios'));
    }

    public function create()
    {
        return view('designer.portofolio.create');
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

    public function edit(Portfolio $portfolio)
    {
        // PROTEKSI
        if ($portfolio->user_id != Auth::id()) {
            abort(403);
        }

        return view('designer.portofolio.edit', compact('portfolio'));
    }

    public function update(Request $request, Portfolio $portfolio)
    {
        // PROTEKSI
        if ($portfolio->user_id != Auth::id()) {
            abort(403);
        }

        $data = $request->validate([
            'title' => 'required',
            'description' => 'nullable',
            'image' => 'nullable|image',
            'price' => 'nullable|numeric'
        ]);

        // HANDLE UPDATE IMAGE
        if ($request->hasFile('image')) {
            // hapus gambar lama
            if ($portfolio->image) {
                Storage::disk('public')->delete($portfolio->image);
            }

            $data['image'] = $request->file('image')->store('portfolio', 'public');
        }

        $portfolio->update($data);

        return redirect()->route('designer.dashboard')
            ->with('success', 'Portfolio berhasil diupdate');
    }

    public function destroy(Portfolio $portfolio)
    {
        // PROTEKSI
        if ($portfolio->user_id != Auth::id()) {
            abort(403);
        }

        // HAPUS FILE GAMBAR
        if ($portfolio->image) {
            Storage::disk('public')->delete($portfolio->image);
        }

        $portfolio->delete();

        return back()->with('success', 'Portfolio dihapus');
    }
}
