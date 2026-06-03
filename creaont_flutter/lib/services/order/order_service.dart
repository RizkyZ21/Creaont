import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../core/api_service.dart';

class OrderService {
  static Future<Map<String, dynamic>> getOrders({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.ordersUrl),
        headers: ApiService.headers(token: token),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrderDetail({
    required String token,
    required int orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.orderDetailUrl(orderId)),
        headers: ApiService.headers(token: token),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String token,
    required int portfolioId,
    String? deadline,
    int? estimatedDays,
    required double totalPrice,
    String description = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.ordersUrl),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          'portfolio_id': portfolioId,
          if (deadline != null) 'deadline': deadline,
          if (estimatedDays != null) 'estimated_days': estimatedDays,
          'total_price': totalPrice,
          'description': description,
        }),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateOrder({
    required String token,
    required int orderId,
    String? status,
    int? progress,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiService.orderDetailUrl(orderId)),
        headers: ApiService.headers(token: token),
        body: jsonEncode({
          if (status != null) 'status': status,
          if (progress != null) 'progress': progress,
        }),
      );
      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> completeServiceOrder({
    required String token,
    required int orderId,
    required PlatformFile deliveryFile,
  }) async {
    try {
      final bytes = deliveryFile.bytes;
      if (bytes == null || bytes.isEmpty) {
        return {'success': false, 'message': 'File hasil tidak dapat dibaca'};
      }

      final dio = Dio(
        BaseOptions(
          headers: ApiService.headersMultipart(token: token),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final response = await dio.post(
        ApiService.orderCompleteServiceUrl(orderId),
        data: FormData.fromMap({
          'delivery_file': MultipartFile.fromBytes(
            bytes,
            filename: deliveryFile.name,
          ),
        }),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': false, 'message': 'Response tidak valid'};
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': false, 'message': 'Koneksi gagal: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> downloadDeliveryFile({
    required String token,
    required int orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.orderDeliveryDownloadUrl(orderId)),
        headers: ApiService.headers(token: token),
      );
      if (response.statusCode == 200) {
        final cd = response.headers['content-disposition'] ?? '';
        final fnMatch = RegExp(r'filename[^;=\n]*=([^;\n]*)').firstMatch(cd);
        final filename = fnMatch != null
            ? fnMatch.group(1)!.trim().replaceAll('"', '')
            : 'delivery-file';
        return {
          'success': true,
          'bytes': response.bodyBytes,
          'filename': filename,
        };
      }

      return _parse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Map<String, dynamic> _parse(http.Response response) {
    if (response.body.trim().startsWith('<')) {
      return {
        'success': false,
        'message': 'Server error (${response.statusCode})',
      };
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Response tidak valid'};
    }
  }
}
