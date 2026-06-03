import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../core/api_service.dart';

class PortfolioService {
  // ── Semua portfolio ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> getPortfolios({
    String? category,
    String? search,
    String type = 'design',
  }) async {
    try {
      final uri = Uri.parse(ApiService.portfolioUrl).replace(
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
          'type': type,
        },
      );
      return _parse(await http.get(uri, headers: ApiService.headers()));
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> getServices({
    String? category,
    String? search,
  }) async {
    try {
      final uri = Uri.parse(ApiService.servicesUrl).replace(
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
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
      final uri = Uri.parse(ApiService.portfolioPopularUrl).replace(
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          'limit': limit.toString(),
        },
      );
      return _parse(await http.get(uri, headers: ApiService.headers()));
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Portfolio milik designer login ────────────────────────────────
  static Future<Map<String, dynamic>> getMyPortfolios({
    required String token,
  }) async {
    try {
      return _parse(
        await http.get(
          Uri.parse(ApiService.myPortfoliosUrl),
          headers: ApiService.headers(token: token),
        ),
      );
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Portfolio milik satu designer ─────────────────────────────────
  static Future<Map<String, dynamic>> getByDesigner(int designerId) async {
    try {
      return _parse(
        await http.get(
          Uri.parse(ApiService.portfolioByDesigner(designerId)),
          headers: ApiService.headers(),
        ),
      );
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Buat portfolio baru — pakai Dio agar multipart benar di Web ───
  static Future<Map<String, dynamic>> createPortfolio({
    required String token,
    required String title,
    required String description,
    required String category,
    required String type,
    required double price,
    required XFile imageXFile,
    PlatformFile? rawFile,
  }) async {
    try {
      final imageBytes = await imageXFile.readAsBytes();
      final imageMime = _mimeFromBytes(imageBytes);
      final imageExt = imageMime.subtype; // png / jpeg / webp
      final imageName = 'thumbnail.$imageExt';

      final rawBytes = rawFile?.bytes;
      if (type == 'design' && (rawBytes == null || rawBytes.isEmpty)) {
        return {'success': false, 'message': 'File raw tidak dapat dibaca'};
      }

      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'category': category,
        'type': type,
        'price': price.toString(),
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: imageName,
          contentType: DioMediaType(imageMime.type, imageMime.subtype),
        ),
        if (rawFile != null && rawBytes != null && rawBytes.isNotEmpty)
          'raw_file': MultipartFile.fromBytes(rawBytes, filename: rawFile.name),
      });

      final dio = _buildDio(token: token);
      final response = await dio.post(ApiService.portfolioUrl, data: formData);
      return _parseDio(response);
    } on DioException catch (e) {
      return _parseDioError(e);
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
    String? type,
    double? price,
    XFile? imageXFile,
    PlatformFile? rawFile,
  }) async {
    try {
      final fields = <String, dynamic>{'_method': 'PUT'};
      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (category != null) fields['category'] = category;
      if (type != null) fields['type'] = type;
      if (price != null) fields['price'] = price.toString();

      if (imageXFile != null) {
        final bytes = await imageXFile.readAsBytes();
        final mime = _mimeFromBytes(bytes);
        fields['image'] = MultipartFile.fromBytes(
          bytes,
          filename: 'thumbnail.${mime.subtype}',
          contentType: DioMediaType(mime.type, mime.subtype),
        );
      }
      if (rawFile != null && rawFile.bytes != null) {
        fields['raw_file'] = MultipartFile.fromBytes(
          rawFile.bytes!,
          filename: rawFile.name,
        );
      }

      final dio = _buildDio(token: token);
      final response = await dio.post(
        ApiService.portfolioDetailUrl(id),
        data: FormData.fromMap(fields),
      );
      return _parseDio(response);
    } on DioException catch (e) {
      return _parseDioError(e);
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
      return _parse(
        await http.delete(
          Uri.parse(ApiService.portfolioDetailUrl(id)),
          headers: ApiService.headers(token: token),
        ),
      );
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Download file raw ─────────────────────────────────────────────
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
        final cd = response.headers['content-disposition'] ?? '';
        final fnMatch = RegExp(r'filename[^;=\n]*=([^;\n]*)').firstMatch(cd);
        final filename = fnMatch != null
            ? fnMatch.group(1)!.trim().replaceAll('"', '')
            : 'file';
        return {
          'success': true,
          'bytes': response.bodyBytes,
          'filename': filename,
        };
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Download gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  static Dio _buildDio({String? token}) {
    final dio = Dio(
      BaseOptions(
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return dio;
  }

  // Deteksi MIME dari magic bytes — akurat tanpa bergantung nama file
  static MediaType _mimeFromBytes(Uint8List bytes) {
    if (bytes.length >= 12) {
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return MediaType('image', 'png');
      }
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return MediaType('image', 'jpeg');
      }
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return MediaType('image', 'webp');
      }
    }
    return MediaType('image', 'jpeg');
  }

  static Map<String, dynamic> _parseDio(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': 'Response tidak valid'};
  }

  static Map<String, dynamic> _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': 'Koneksi gagal: ${e.message}'};
  }

  static Map<String, dynamic> _parse(http.Response response) {
    if (response.body.trim().startsWith('<')) {
      return {
        'success': false,
        'message': 'Server error (${response.statusCode})',
      };
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
