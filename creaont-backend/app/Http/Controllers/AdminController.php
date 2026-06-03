<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Orders;
use App\Models\Portfolio;
use App\Models\Category;
use App\Models\Chat;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class AdminController extends Controller
{
    private function stats(): array
    {
        return [
            'total_users' => User::count(),
            'total_customers' => User::where('role', 'customer')->count(),
            'total_designers' => User::where('role', 'designer')->count(),
            'total_admins' => User::where('role', 'admin')->count(),
            'total_orders' => Orders::count(),
            'pending_orders' => Orders::where('status', 'pending')->count(),
            'in_progress_orders' => Orders::where('status', 'in_progress')->count(),
            'completed_orders' => Orders::where('status', 'completed')->count(),
            'total_portfolios' => Portfolio::count(),
            'total_categories' => Category::count(),
            'total_chats' => Chat::count(),
            'total_reviews' => Review::count(),
            'total_revenue' => Orders::sum('total_price'),
        ];
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if (!Auth::attempt($credentials, $request->boolean('remember'))) {
            return back()->withInput($request->only('email'))->with('error', 'Email atau password salah');
        }

        if ($request->user()->role !== 'admin') {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return back()->withInput($request->only('email'))->with('error', 'Akun ini bukan admin');
        }

        $request->session()->regenerate();

        return redirect()->intended(route('admin.dashboard'));
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login')->with('success', 'Logout berhasil');
    }

    /**
     * Admin Dashboard
     */
    public function dashboard()
    {
        $stats = $this->stats();

        $recent_orders = Orders::with(['customer', 'designer', 'portfolio'])
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        return view('admin.pages.dashboard', compact('stats', 'recent_orders'));
    }

    public function summary(Request $request)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $recentOrders = Orders::with(['customer', 'designer', 'portfolio'])
            ->orderBy('created_at', 'desc')
            ->limit(8)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => $this->stats(),
                'recent_orders' => $recentOrders,
            ],
        ]);
    }

    /**
     * Users Management
     */
    public function users()
    {
        $users = User::paginate(15);
        return view('admin.pages.users', compact('users'));
    }

    public function createUser()
    {
        return view('admin.pages.create-user');
    }

    public function storeUser(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|in:customer,designer,admin',
        ]);

        User::create($data);

        return redirect()->route('admin.users')->with('success', 'User berhasil dibuat');
    }

    public function editUser($id)
    {
        $user = User::findOrFail($id);
        return view('admin.pages.edit-user', compact('user'));
    }

    public function updateUser(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $id,
            'role' => 'required|in:customer,designer,admin',
        ]);

        if ($user->role === 'admin'
            && $request->role !== 'admin'
            && User::where('role', 'admin')->count() <= 1) {
            return back()->withInput()->with('error', 'Minimal harus ada satu admin aktif');
        }

        $user->update($request->only('name', 'email', 'role'));

        return redirect()->route('admin.users')->with('success', 'User berhasil diperbarui');
    }

    public function deleteUser($id)
    {
        $user = User::findOrFail($id);

        if (auth()->id() === $user->id) {
            return back()->with('error', 'Kamu tidak bisa menghapus akun admin yang sedang dipakai');
        }

        if ($user->role === 'admin' && User::where('role', 'admin')->count() <= 1) {
            return back()->with('error', 'Minimal harus ada satu admin aktif');
        }

        $user->delete();

        return redirect()->route('admin.users')->with('success', 'User berhasil dihapus');
    }

    /**
     * Categories Management
     */
    public function categories()
    {
        $categories = Category::orderBy('name')->paginate(15);
        return view('admin.pages.categories', compact('categories'));
    }

    public function createCategory()
    {
        return view('admin.pages.create-category');
    }

    public function storeCategory(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name',
            'description' => 'nullable|string',
            'is_active' => 'nullable|boolean',
        ]);

        $data['is_active'] = $request->boolean('is_active');
        Category::create($data);

        return redirect()->route('admin.categories')->with('success', 'Category berhasil dibuat');
    }

    public function editCategory($id)
    {
        $category = Category::findOrFail($id);
        return view('admin.pages.edit-category', compact('category'));
    }

    public function updateCategory(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:100', Rule::unique('categories', 'name')->ignore($category->id)],
            'description' => 'nullable|string',
            'is_active' => 'nullable|boolean',
        ]);

        $oldName = $category->name;
        $data['is_active'] = $request->boolean('is_active');
        $category->update($data);

        if ($oldName !== $category->name) {
            Portfolio::where('category', $oldName)->update(['category' => $category->name]);
        }

        return redirect()->route('admin.categories')->with('success', 'Category berhasil diperbarui');
    }

    public function deleteCategory($id)
    {
        $category = Category::findOrFail($id);
        $usedCount = Portfolio::where('category', $category->name)->count();

        if ($usedCount > 0) {
            return back()->with('error', "Category masih dipakai oleh {$usedCount} portfolio");
        }

        $category->delete();

        return redirect()->route('admin.categories')->with('success', 'Category berhasil dihapus');
    }

    /**
     * Orders Management
     */
    public function orders()
    {
        $orders = Orders::with(['customer', 'designer', 'portfolio'])
            ->orderBy('created_at', 'desc')
            ->paginate(15);
        
        return view('admin.pages.orders', compact('orders'));
    }

    public function viewOrder($id)
    {
        $order = Orders::with(['customer', 'designer', 'portfolio'])->findOrFail($id);
        return view('admin.pages.view-order', compact('order'));
    }

    public function updateOrderStatus(Request $request, $id)
    {
        $order = Orders::findOrFail($id);
        
        $request->validate([
            'status' => 'required|in:pending,in_progress,revision,completed,cancelled',
            'progress' => 'sometimes|integer|min:0|max:100',
        ]);

        $order->update($request->only('status', 'progress'));

        return redirect()->back()->with('success', 'Order status berhasil diperbarui');
    }

    /**
     * Portfolios Management
     */
    public function portfolios()
    {
        $portfolios = Portfolio::with('user')
            ->orderBy('created_at', 'desc')
            ->paginate(15);
        
        return view('admin.pages.portfolios', compact('portfolios'));
    }

    public function deletePortfolio($id)
    {
        $portfolio = Portfolio::findOrFail($id);
        $portfolio->delete();

        return redirect()->route('admin.portfolios')->with('success', 'Portfolio berhasil dihapus');
    }

    /**
     * Chats Management
     */
    public function chats()
    {
        $chats = Chat::with(['order', 'sender'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        
        return view('admin.pages.chats', compact('chats'));
    }

    /**
     * Reviews Management
     */
    public function reviews()
    {
        $reviews = Review::with(['order', 'designer', 'customer'])
            ->orderBy('created_at', 'desc')
            ->paginate(15);
        
        return view('admin.pages.reviews', compact('reviews'));
    }

    /**
     * Analytics/Reports
     */
    public function analytics()
    {
        $orders_by_month = Orders::selectRaw('MONTH(created_at) as month, COUNT(*) as count')
            ->groupBy('month')
            ->get();

        $revenue_by_month = Orders::selectRaw('MONTH(created_at) as month, SUM(total_price) as total')
            ->groupBy('month')
            ->get();

        $designers_top = Orders::selectRaw('designer_id, COUNT(*) as orders_count, SUM(total_price) as revenue')
            ->groupBy('designer_id')
            ->with('designer')
            ->orderByDesc('orders_count')
            ->limit(10)
            ->get();

        return view('admin.pages.analytics', compact('orders_by_month', 'revenue_by_month', 'designers_top'));
    }
}
