<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // ================= WEB =================

    public function loginForm()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $data = $request->only('email', 'password');

        if (Auth::attempt($data)) {
            if (Auth::user()->role == 'designer') {
                return redirect('/designer/dashboard');
            } else {
                return redirect('/dashboard');
            }
        }

        return back()->with('error', 'Email atau password salah');
    }

    public function registerForm()
    {
        return view('auth.register');
    }

    public function register(Request $request)
    {
        $data = $request->all();
        $data['password'] = bcrypt($data['password']);

        User::create($data);

        return "REGISTER BERHASIL";
    }

    public function logout()
    {
        Auth::logout();
        return redirect('/');
    }

    // ================= API =================

    public function loginApi(Request $request)
    {
        // 🔥 VALIDASI
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => $user
        ]);
    }

    public function registerApi(Request $request)
    {
        // 🔥 VALIDASI
        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password),
            'role' => $request->role
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Register berhasil',
            'token' => $token,
            'user' => $user
        ]);
    }
}
