<?php

namespace App\Http\Controllers;

use App\Models\Portfolio;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PortfolioController extends Controller
{
    public function index(Request $request)
    {
        $query = Portfolio::with('user:id,name')
            ->where('type', $request->input('type', 'design'));

        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }
        if ($request->filled('search')) {
            $this->applySearch($query, $request->search);
        }

        return response()->json(['success' => true, 'data' => $query->latest()->get()]);
    }

    public function popular(Request $request)
    {
        $query = Portfolio::with('user:id,name')
            ->where('type', 'design')
            ->withCount('orders')
            ->withAvg('reviews', 'rating')
            ->orderByDesc('orders_count')
            ->orderByDesc('created_at');

        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }
        if ($request->filled('search')) {
            $this->applySearch($query, $request->search);
        }

        return response()->json([
            'success' => true,
            'data'    => $query->limit((int) $request->input('limit', 10))->get(),
        ]);
    }

    public function byDesigner($designerId)
    {
        $portfolios = Portfolio::with('user:id,name')
            ->where('user_id', $designerId)
            ->withCount('orders')
            ->withAvg('reviews', 'rating')
            ->orderByDesc('orders_count')
            ->latest()
            ->get();

        return response()->json(['success' => true, 'data' => $portfolios]);
    }

    // ── Listing jasa saja (type = service) ───────────────────────────
    public function services(Request $request)
    {
        $query = Portfolio::with('user:id,name')
            ->where('type', 'service')
            ->withAvg('reviews', 'rating');

        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }
        if ($request->filled('search')) {
            $this->applySearch($query, $request->search);
        }

        return response()->json(['success' => true, 'data' => $query->latest()->get()]);
    }

    public function categories(Request $request)
    {
        $cats = Portfolio::distinct()->pluck('category')->filter()->values();
        return response()->json(['success' => true, 'data' => $cats]);
    }

    // ── Designer: buat portfolio ──────────────────────────────────────
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
            'type'        => 'sometimes|in:design,service',
            'price'       => 'required|numeric|min:0',
            'image'       => 'required|file|max:4096',
            'raw_file'    => 'sometimes|nullable|file|max:102400',
        ]);

        $type = $request->input('type', 'design');

        // Validasi image bytes (aman untuk web — tidak pakai getRealPath)
        $imageError = $this->validateImageBytes($request->file('image'));
        if ($imageError) return $imageError;

        // Raw file wajib hanya untuk type=design; type=service tidak butuh raw file
        if ($type === 'design' && !$request->hasFile('raw_file')) {
            return response()->json([
                'success' => false,
                'message' => 'File desain asli wajib diunggah untuk karya jadi',
            ], 422);
        }

        $imagePath = $request->file('image')->store('portfolios/thumbnails', 'public');

        // Hanya simpan raw_file jika type=design
        $rawPath = $rawFileName = $rawFileType = null;
        if ($type === 'design' && $request->hasFile('raw_file')) {
            $rawFile     = $request->file('raw_file');
            $rawPath     = $rawFile->store('portfolios/raw', 'local');
            $rawFileName = $rawFile->getClientOriginalName();
            $rawFileType = strtolower($rawFile->getClientOriginalExtension());
        }

        $portfolio = Portfolio::create([
            'user_id'       => $user->id,
            'title'         => $request->title,
            'description'   => $request->description,
            'category'      => $request->category,
            'type'          => $type,
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
            'type'        => 'sometimes|in:design,service',
            'price'       => 'sometimes|numeric|min:0',
            'image'       => 'sometimes|file|max:4096',
            'raw_file'    => 'sometimes|nullable|file|max:102400',
        ]);

        if ($request->hasFile('image')) {
            $imageError = $this->validateImageBytes($request->file('image'));
            if ($imageError) return $imageError;
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

    public function myPortfolios(Request $request)
    {
        $portfolios = Portfolio::where('user_id', $request->user()->id)
            ->withCount('orders')
            ->withAvg('reviews', 'rating')
            ->orderByDesc('orders_count')
            ->latest()
            ->get();

        return response()->json(['success' => true, 'data' => $portfolios]);
    }

    public function download(Request $request, $id)
    {
        $user      = $request->user();
        $portfolio = Portfolio::findOrFail($id);

        $isOwner   = $portfolio->user_id === $user->id;
        $isAdmin   = $user->role === 'admin';
        $hasBought = $portfolio->isBoughtBy($user->id);

        if (!$isOwner && !$isAdmin && !$hasBought) {
            return response()->json(['success' => false, 'message' => 'Anda belum membeli produk ini'], 403);
        }

        if (!$portfolio->raw_file || !Storage::disk('local')->exists($portfolio->raw_file)) {
            return response()->json(['success' => false, 'message' => 'File tidak ditemukan'], 404);
        }

        return Storage::disk('local')->download(
            $portfolio->raw_file,
            $portfolio->raw_file_name ?? 'file.' . $portfolio->raw_file_type
        );
    }

    // ── Validasi image dari bytes — aman untuk web ────────────────────
    // (tidak pakai getRealPath() yang bisa false di upload web)
    private function validateImageBytes($image)
    {
        if (!$image || !$image->isValid()) {
            return response()->json([
                'success' => false,
                'message' => 'Gambar tidak dapat dibaca. Pilih file lain.',
            ], 422);
        }

        // Baca 12 byte pertama untuk cek magic bytes
        $handle = fopen($image->getRealPath() ?: $image->path(), 'rb');
        if (!$handle) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat membaca file gambar.',
            ], 422);
        }
        $header = fread($handle, 12);
        fclose($handle);

        $isPng  = substr($header, 0, 4) === "\x89PNG";
        $isJpeg = substr($header, 0, 3) === "\xFF\xD8\xFF";
        $isWebp = substr($header, 0, 4) === 'RIFF' && substr($header, 8, 4) === 'WEBP';

        if (!$isPng && !$isJpeg && !$isWebp) {
            return response()->json([
                'success' => false,
                'message' => 'Format gambar tidak valid. Gunakan JPG, PNG, atau WEBP.',
            ], 422);
        }

        return null;
    }

    private function applySearch($query, string $search): void
    {
        $term = trim($search);
        if ($term === '') return;

        $query->where(function ($q) use ($term) {
            $like = '%' . $term . '%';

            $q->where('title', 'like', $like)
                ->orWhere('description', 'like', $like)
                ->orWhere('category', 'like', $like)
                ->orWhereHas('user', function ($userQuery) use ($like) {
                    $userQuery->where('name', 'like', $like);
                });
        });
    }
}
