<?php

namespace App\Http\Controllers;

use App\Models\Portfolio;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PortfolioController extends Controller
{
    public function categories()
    {
        $categories = Category::where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name', 'description']);

        return response()->json(['success' => true, 'data' => $categories]);
    }

    // ── Public: semua portfolio ───────────────────────────────────────
    public function index(Request $request)
    {
        $type = $request->input('type', 'design');
        if ($type === 'product') {
            $type = 'design';
        }

        $query = Portfolio::with('user:id,name,avatar')->where('type', $type);

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
        $type = $request->input('type', 'design');
        if ($type === 'product') {
            $type = 'design';
        }

        $query = Portfolio::with('user:id,name,avatar')
            ->where('type', $type)
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
        $type = $request->input('type', 'design');
        if ($type === 'product') {
            $type = 'design';
        }

        $portfolios = Portfolio::with('user:id,name,avatar')
            ->where('user_id', $designerId)
            ->where('type', $type)
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
            'type'        => 'sometimes|in:design,service,product',
            'price'       => 'required|numeric|min:0',
            'image'       => 'required|file|max:4096',
            'raw_file'    => 'sometimes|file|max:102400',
        ]);

        $type = $request->input('type', 'design');
        if ($type === 'product') {
            $type = 'design';
        }
        if ($type === 'design' && !$request->hasFile('raw_file')) {
            return response()->json([
                'success' => false,
                'message' => 'File desain asli wajib diunggah untuk desain jadi',
            ], 422);
        }

        $imageError = $this->validateImageFile($request->file('image'));
        if ($imageError) {
            return $imageError;
        }

        // Simpan thumbnail
        $imagePath = $request->file('image')->store('portfolios/thumbnails', 'public');

        // Simpan file raw — taruh di disk 'local' (tidak accessible publik)
        $rawPath = null;
        $rawFileName = null;
        $rawFileType = null;
        if ($request->hasFile('raw_file')) {
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
            'type'        => 'sometimes|in:design,service,product',
            'price'       => 'sometimes|numeric|min:0',
            'image'       => 'sometimes|file|max:4096',
            'raw_file'    => 'sometimes|file|max:102400',
        ]);

        if ($request->hasFile('image')) {
            $imageError = $this->validateImageFile($request->file('image'));
            if ($imageError) {
                return $imageError;
            }

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

        $data = $request->only('title', 'description', 'category', 'type', 'price');
        if (($data['type'] ?? null) === 'product') {
            $data['type'] = 'design';
        }
        $portfolio->fill($data);
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

        // Cegah hapus jika masih ada order aktif (pending / in_progress)
        $activeOrders = $portfolio->orders()
            ->whereIn('status', ['pending', 'in_progress'])
            ->exists();

        if ($activeOrders) {
            return response()->json([
                'success' => false,
                'message' => 'Portfolio tidak dapat dihapus karena masih ada order yang sedang berjalan.',
            ], 422);
        }

        // Putus relasi pada order yang sudah selesai/dibatalkan agar FK tidak melanggar
        $portfolio->orders()->update(['portfolio_id' => null]);

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

    public function services(Request $request)
    {
        $query = Portfolio::with('user:id,name,avatar')
            ->where('type', 'service')
            ->withCount('orders')
            ->orderByDesc('orders_count')
            ->latest();

        if ($request->filled('category') && $request->category !== 'All') {
            $query->where('category', $request->category);
        }
        if ($request->filled('search')) {
            $search = '%' . $request->search . '%';
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', $search)
                    ->orWhere('description', 'like', $search)
                    ->orWhereHas('user', fn ($u) => $u->where('name', 'like', $search));
            });
        }

        return response()->json(['success' => true, 'data' => $query->get()]);
    }

    // ── Download file raw — hanya jika sudah beli / designer sendiri ──
    public function download(Request $request, $id)
    {
        $user      = $request->user();
        $portfolio = Portfolio::findOrFail($id);

        $isOwner   = $portfolio->user_id === $user->id;
        $isAdmin   = $user->role === 'admin';
        $hasBought = $portfolio->isBoughtBy($user->id);

        if (!in_array($portfolio->type, ['design', 'product'], true)) {
            return response()->json([
                'success' => false,
                'message' => 'Portfolio jasa tidak memiliki file desain untuk didownload',
            ], 422);
        }

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

    private function validateImageFile($image)
    {
        if (!$image || !$image->isValid()) {
            return response()->json([
                'success' => false,
                'message' => 'Gambar tidak dapat dibaca. Pilih file lain.',
            ], 422);
        }

        $imgBytes = file_get_contents($image->getRealPath(), false, null, 0, 12);
        $isPng  = substr($imgBytes, 0, 4) === "\x89PNG";
        $isJpeg = substr($imgBytes, 0, 3) === "\xFF\xD8\xFF";
        $isWebp = substr($imgBytes, 0, 4) === 'RIFF' && substr($imgBytes, 8, 4) === 'WEBP';

        if (!$isPng && !$isJpeg && !$isWebp) {
            return response()->json([
                'success' => false,
                'message' => 'Format gambar tidak valid. Gunakan JPG, PNG, atau WEBP.',
            ], 422);
        }

        return null;
    }
}
