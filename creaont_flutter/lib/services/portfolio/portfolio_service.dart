import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../core/api_service.dart';

class PortfolioService {

  // ── Semua portfolio ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> getPortfolios({
    String? category,
    String? search,
  }) async {
    try {
      final uri = Uri.parse(ApiService.portfolioUrl).replace(queryParameters: {
        if (category != null && category != 'All') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      return _parse(await http.get(uri, headers: ApiService.headers()));
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Portfolio populer ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getPopularPortfolios({
    String? category,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(ApiService.portfolioPopularUrl).replace(queryParameters: {
        if (category != null && category != 'All') 'category': category,
        'limit': limit.toString(),
      });
      return _parse(await http.get(uri, headers: ApiService.headers()));
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Portfolio milik designer login ────────────────────────────────
  static Future<Map<String, dynamic>> getMyPortfolios({required String token}) async {
    try {
      return _parse(await http.get(
        Uri.parse(ApiService.myPortfoliosUrl),
        headers: ApiService.headers(token: token),
      ));
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Portfolio milik satu designer ─────────────────────────────────
  static Future<Map<String, dynamic>> getByDesigner(int designerId) async {
    try {
      return _parse(await http.get(
        Uri.parse(ApiService.portfolioByDesigner(designerId)),
        headers: ApiService.headers(),
      ));
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Buat portfolio baru (wajib image + rawFile) ───────────────────
  static Future<Map<String, dynamic>> createPortfolio({
    required String token,
    required String title,
    required String description,
    required String category,
    required double price,
    required XFile imageXFile,
    required PlatformFile rawFile,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiService.portfolioUrl));
      request.headers.addAll(ApiService.headersMultipart(token: token));

      request.fields['title']       = title;
      request.fields['description'] = description;
      request.fields['category']    = category;
      request.fields['price']       = price.toString();

      // Thumbnail — pakai bytes agar support Web
      final imageBytes = await imageXFile.readAsBytes();
      final imageName  = imageXFile.name.isNotEmpty ? imageXFile.name : 'thumbnail.jpg';
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
      ));

      // Raw file — bytes sudah di-load oleh file_picker (withData: true)
      final rawBytes = rawFile.bytes;
      if (rawBytes == null || rawBytes.isEmpty) {
        return {'success': false, 'message': 'File raw tidak dapat dibaca'};
      }
      request.files.add(http.MultipartFile.fromBytes(
        'raw_file',
        rawBytes,
        filename: rawFile.name,
      ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Update portfolio ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> updatePortfolio({
    required String token,
    required int id,
    String? title,
    String? description,
    String? category,
    double? price,
    XFile? imageXFile,
    PlatformFile? rawFile,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiService.portfolioDetailUrl(id)));
      request.headers.addAll(ApiService.headersMultipart(token: token));
      request.fields['_method'] = 'PUT';

      if (title != null)       request.fields['title']       = title;
      if (description != null) request.fields['description'] = description;
      if (category != null)    request.fields['category']    = category;
      if (price != null)       request.fields['price']       = price.toString();

      if (imageXFile != null) {
        final bytes = await imageXFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageXFile.name));
      }
      if (rawFile != null && rawFile.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('raw_file', rawFile.bytes!, filename: rawFile.name));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Hapus portfolio ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> deletePortfolio({
    required String token,
    required int id,
  }) async {
    try {
      return _parse(await http.delete(
        Uri.parse(ApiService.portfolioDetailUrl(id)),
        headers: ApiService.headers(token: token),
      ));
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Download file raw — return bytes + filename ───────────────────
  // Hanya berhasil jika sudah beli (backend enforce)
  static Future<Map<String, dynamic>> downloadRawFile({
    required String token,
    required int portfolioId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.portfolioDownloadUrl(portfolioId)),
        headers: ApiService.headers(token: token),
      );

      if (response.statusCode == 200) {
        // Ambil nama file dari Content-Disposition header
        final cd          = response.headers['content-disposition'] ?? '';
        final fnMatch     = RegExp(r'filename[^;=\n]*=([^;\n]*)').firstMatch(cd);
        final filename    = fnMatch != null
            ? fnMatch.group(1)!.trim().replaceAll('"', '')
            : 'file';

        return {
          'success':  true,
          'bytes':    response.bodyBytes,
          'filename': filename,
        };
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? 'Download gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Map<String, dynamic> _parse(http.Response response) {
    if (response.body.trim().startsWith('<')) {
      return {'success': false, 'message': 'Server error (${response.statusCode})'};
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return {'success': true, 'data': decoded};
      return decoded as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Response tidak valid'};
    }
  }
}
