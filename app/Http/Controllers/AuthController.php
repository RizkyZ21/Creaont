<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // LOGIN FORM
    public function loginForm()
    {
        return view('auth.login');
    }

    // PROSES LOGIN
    public function login(Request $request)
    {
        $data = $request->only('email', 'password');

        if (Auth::attempt($data)) {

            // 🔥 CEK ROLE
            if (Auth::user()->role == 'designer') {
                return redirect('/designer/dashboard');
            } else {
                return redirect('/dashboard');
            }
        }

        return back()->with('error', 'Email atau password salah');
    }

    // REGISTER FORM
    public function registerForm()
    {
        return view('auth.register');
    }

    // PROSES REGISTER
    public function register(Request $request)
{
    $data = $request->all();

    $data['password'] = bcrypt($data['password']);

    User::create($data);

    return "REGISTER BERHASIL";
}

    // LOGOUT
    public function logout()
    {
        Auth::logout();
        return redirect('/');
    }
}