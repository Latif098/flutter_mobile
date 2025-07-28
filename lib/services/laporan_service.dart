import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tugasakhir_mobile/models/pesanan_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';
import 'package:tugasakhir_mobile/services/api_config.dart';
import 'package:intl/intl.dart';

class LaporanService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Get summary data for dashboard
  Future<Map<String, dynamic>> getSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      final queryParams = {
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        if (status != null) 'status': status.toLowerCase(),
      };

      final uri = Uri.parse('$_baseUrl/laporan/summary').replace(
        queryParameters: queryParams,
      );

      print('Laporan Summary Request: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat data summary',
        };
      }
    } catch (e) {
      print('Error in getSummary: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get pesanan list for report
  Future<Map<String, dynamic>> getPesananLaporan({
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      final queryParams = {
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        if (status != null) 'status': status.toLowerCase(),
      };

      final uri = Uri.parse('$_baseUrl/laporan/pesanan').replace(
        queryParameters: queryParams,
      );

      print('Laporan Pesanan Request: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<PesananModel> pesananList =
            data.map((item) => PesananModel.fromJson(item)).toList();

        return {
          'success': true,
          'data': pesananList,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat data pesanan',
        };
      }
    } catch (e) {
      print('Error in getPesananLaporan: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get chart data for visualization
  Future<Map<String, dynamic>> getChartData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      final queryParams = {
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      };

      final uri = Uri.parse('$_baseUrl/laporan/chart').replace(
        queryParameters: queryParams,
      );

      print('Laporan Chart Request: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data.cast<Map<String, dynamic>>(),
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat data chart',
        };
      }
    } catch (e) {
      print('Error in getChartData: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Export laporan
  Future<Map<String, dynamic>> exportLaporan({
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      // Request permission for storage
      var permissionStatus = await Permission.storage.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.storage.request();
        if (!permissionStatus.isGranted) {
          return {
            'success': false,
            'message': 'Izin akses storage diperlukan untuk mengunduh file',
          };
        }
      }

      final queryParams = {
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        if (status != null) 'status': status.toLowerCase(),
        'format': 'pdf',
      };

      final url = '$_baseUrl/laporan/export';
      final uri = Uri.parse(url).replace(queryParameters: queryParams);

      print('Export Laporan Request: $uri');

      // Use Dio for file download
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Accept'] = 'application/pdf';

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        return {
          'success': false,
          'message': 'Tidak dapat mengakses direktori download',
        };
      }

      // Create filename
      final filename =
          'laporan-pesanan-${DateFormat('yyyy-MM-dd').format(startDate)}-to-${DateFormat('yyyy-MM-dd').format(endDate)}.pdf';
      final filePath = '${directory.path}/$filename';

      print('Downloading to: $filePath');

      // Download file
      await dio.download(
        url,
        filePath,
        queryParameters: queryParams,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
                'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      return {
        'success': true,
        'message': 'Laporan berhasil diunduh ke: $filePath',
        'file_path': filePath,
      };
    } catch (e) {
      print('Error in exportLaporan: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
