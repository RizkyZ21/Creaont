<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        try {
            $request->validate([
                'name'     => 'required|string|max:255',
                'email'    => 'required|email|unique:users,email',
                'password' => 'required|string|min:8',
                'role'     => 'required|in:customer,designer,admin',
            ]);

            $user = User::create([
                'name'     => $request->name,
                'email'    => $request->email,
                'role'     => $request->role,
                'password' => Hash::make($request->password),
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Register success',
                'token'   => $token,
                'user'    => $user,
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function login(Request $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['success' => false, 'message' => 'Email atau password salah'], 401);
        }

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login success',
            'token'   => $token,
            'user'    => $user,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['success' => true, 'message' => 'Logout berhasil']);
    }

    public function me(Request $request)
    {
        return response()->json(['success' => true, 'user' => $request->user()]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'bio' => 'nullable|string|max:1000',
            'avatar' => 'sometimes|file|max:4096',
        ]);

        $data = $request->only('name', 'email', 'bio');

        if ($request->hasFile('avatar')) {
            $bytes = file_get_contents($request->file('avatar')->getRealPath(), false, null, 0, 12);
            $isPng  = substr($bytes, 0, 4) === "\x89PNG";
            $isJpeg = substr($bytes, 0, 3) === "\xFF\xD8\xFF";
            $isWebp = substr($bytes, 0, 4) === 'RIFF' && substr($bytes, 8, 4) === 'WEBP';
            if (!$isPng && !$isJpeg && !$isWebp) {
                return response()->json([
                    'success' => false,
                    'message' => 'Format foto tidak valid. Gunakan JPG, PNG, atau WEBP.',
                ], 422);
            }

            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }
            $data['avatar'] = $request->file('avatar')->store('profiles', 'public');
        }

        $user->update($data);
        return response()->json(['success' => true, 'user' => $user->fresh()]);
    }

    // ── Upgrade role customer → designer (permanen) ───────────────────
    public function upgradeToDesigner(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'designer') {
            return response()->json(['success' => false, 'message' => 'Akun sudah menjadi designer'], 422);
        }
        if ($user->role === 'admin') {
            return response()->json(['success' => false, 'message' => 'Admin tidak bisa diubah rolenya'], 422);
        }

        $user->role = 'designer';
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil ditingkatkan menjadi Designer',
            'user'    => $user->fresh(),
        ]);
    }
}
