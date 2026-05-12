<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Orders;
use App\Models\Portfolio;
use App\Models\Chat;
use App\Models\Review;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Admin Dashboard
     */
    public function dashboard()
    {
        $stats = [
            'total_users' => User::count(),
            'total_customers' => User::where('role', 'customer')->count(),
            'total_designers' => User::where('role', 'designer')->count(),
            'total_orders' => Orders::count(),
            'pending_orders' => Orders::where('status', 'pending')->count(),
            'total_portfolios' => Portfolio::count(),
            'total_revenue' => Orders::sum('total_price'),
        ];

        $recent_orders = Orders::with(['customer', 'designer'])
            ->latest()
            ->limit(10)
            ->get();

        return view('admin.pages.dashboard', compact('stats', 'recent_orders'));
    }

    /**
     * Users Management
     */
    public function users()
    {
        $users = User::paginate(15);
        return view('admin.pages.users', compact('users'));
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

        $user->update($request->only('name', 'email', 'role'));

        return redirect()->route('admin.users')->with('success', 'User berhasil diperbarui');
    }

    public function deleteUser($id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        return redirect()->route('admin.users')->with('success', 'User berhasil dihapus');
    }

    /**
     * Orders Management
     */
    public function orders()
    {
        $orders = Orders::with(['customer', 'designer', 'portfolio'])
            ->latest()
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
            ->latest()
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
            ->latest()
            ->paginate(20);
        
        return view('admin.pages.chats', compact('chats'));
    }

    /**
     * Reviews Management
     */
    public function reviews()
    {
        $reviews = Review::with(['order', 'designer', 'customer'])
            ->latest()
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
