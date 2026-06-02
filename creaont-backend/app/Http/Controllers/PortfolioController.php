<?php

namespace App\Http\Controllers;

use App\Models\Portfolio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PortfolioController extends Controller
{
    // ── Public: semua portfolio ───────────────────────────────────────
    public function index(Request $request)
    {
        $query = Portfolio::with('user:id,name')->where('type', 'product');

        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }
        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        return response()->json(['success' => true, 'data' => $query->latest()->get()]);
    }

    // ── Public: portfolio populer ─────────────────────────────────────
    public function popular(Request $request)
    {
        $query = Portfolio::with('user:id,name')
            ->where('type', 'product')
            ->withCount('orders')
            ->orderByDesc('orders_count')
            ->orderByDesc('created_at');

        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }

        $portfolios = $query->limit((int) $request->input('limit', 10))->get();

        return response()->json(['success' => true, 'data' => $portfolios]);
    }

    // ── Public: portfolio milik satu designer ─────────────────────────
    public function byDesigner($designerId)
    {
        $portfolios = Portfolio::with('user:id,name')
            ->where('user_id', $designerId)
            ->where('type', 'product')
            ->withCount('orders')
            ->orderByDesc('orders_count')
            ->latest()
            ->get();

        return response()->json(['success' => true, 'data' => $portfolios]);
    }

    // ── Designer: buat portfolio (wajib image + raw_file) ────────────
    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'designer') {
            return response()->json(['success' => false, 'message' => 'Hanya designer yang bisa membuat portfolio'], 403);
        }

        $request->validate([
            'title'       => 'required|string|max:255',
            'description' => 'required|string',
            'category'    => 'required|string|max:100',
            'type'        => 'sometimes|in:product,service',
            'price'       => 'required|numeric|min:0',
            'image'       => 'required|image|mimes:jpg,jpeg,png,webp|max:4096',
            'raw_file'    => 'required|file|max:102400',
        ]);

        // Simpan thumbnail
        $imagePath = $request->file('image')->store('portfolios/thumbnails', 'public');

        // Simpan file raw — taruh di disk 'local' (tidak accessible publik)
        $rawFile     = $request->file('raw_file');
        $rawPath     = $rawFile->store('portfolios/raw', 'local');
        $rawFileName = $rawFile->getClientOriginalName();
        $rawFileType = strtolower($rawFile->getClientOriginalExtension());

        $portfolio = Portfolio::create([
            'user_id'       => $user->id,
            'title'         => $request->title,
            'description'   => $request->description,
            'category'      => $request->category,
            'type'          => $request->input('type', 'product'),
            'price'         => $request->price,
            'image'         => $imagePath,
            'raw_file'      => $rawPath,
            'raw_file_name' => $rawFileName,
            'raw_file_type' => $rawFileType,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Portfolio berhasil dibuat',
            'data'    => $portfolio->load('user:id,name'),
        ], 201);
    }

    // ── Designer: update portfolio ────────────────────────────────────
    public function update(Request $request, $id)
    {
        $user      = $request->user();
        $portfolio = Portfolio::findOrFail($id);

        if ($portfolio->user_id !== $user->id && $user->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'title'       => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'category'    => 'sometimes|string|max:100',
            'type'        => 'sometimes|in:product,service',
            'price'       => 'sometimes|numeric|min:0',
            'image'       => 'sometimes|image|mimes:jpg,jpeg,png,webp|max:4096',
            'raw_file'    => 'sometimes|file|max:102400',
        ]);

        if ($request->hasFile('image')) {
            if ($portfolio->image) Storage::disk('public')->delete($portfolio->image);
            $portfolio->image = $request->file('image')->store('portfolios/thumbnails', 'public');
        }

        if ($request->hasFile('raw_file')) {
            if ($portfolio->raw_file) Storage::disk('local')->delete($portfolio->raw_file);
            $rawFile                  = $request->file('raw_file');
            $portfolio->raw_file      = $rawFile->store('portfolios/raw', 'local');
            $portfolio->raw_file_name = $rawFile->getClientOriginalName();
            $portfolio->raw_file_type = strtolower($rawFile->getClientOriginalExtension());
        }

        $portfolio->fill($request->only('title', 'description', 'category', 'type', 'price'));
        $portfolio->save();

        return response()->json([
            'success' => true,
            'message' => 'Portfolio diperbarui',
            'data'    => $portfolio->fresh()->load('user:id,name'),
        ]);
    }

    // ── Designer: hapus portfolio ─────────────────────────────────────
    public function destroy(Request $request, $id)
    {
        $user      = $request->user();
        $portfolio = Portfolio::findOrFail($id);

        if ($portfolio->user_id !== $user->id && $user->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        if ($portfolio->image)    Storage::disk('public')->delete($portfolio->image);
        if ($portfolio->raw_file) Storage::disk('local')->delete($portfolio->raw_file);
        $portfolio->delete();

        return response()->json(['success' => true, 'message' => 'Portfolio dihapus']);
    }

    // ── Designer: portfolio milik sendiri ─────────────────────────────
    public function myPortfolios(Request $request)
    {
        $portfolios = Portfolio::where('user_id', $request->user()->id)
            ->withCount('orders')
            ->orderByDesc('orders_count')
            ->latest()
            ->get();

        return response()->json(['success' => true, 'data' => $portfolios]);
    }

    // ── Download file raw — hanya jika sudah beli / designer sendiri ──
    public function download(Request $request, $id)
    {
        $user      = $request->user();
        $portfolio = Portfolio::findOrFail($id);

        $isOwner   = $portfolio->user_id === $user->id;
        $isAdmin   = $user->role === 'admin';
        $hasBought = $portfolio->isBoughtBy($user->id);

        if (!$isOwner && !$isAdmin && !$hasBought) {
            return response()->json([
                'success' => false,
                'message' => 'Anda belum membeli produk ini',
            ], 403);
        }

        if (!$portfolio->raw_file || !Storage::disk('local')->exists($portfolio->raw_file)) {
            return response()->json(['success' => false, 'message' => 'File tidak ditemukan'], 404);
        }

        return Storage::disk('local')->download(
            $portfolio->raw_file,
            $portfolio->raw_file_name ?? 'file.' . $portfolio->raw_file_type
        );
    }
}
