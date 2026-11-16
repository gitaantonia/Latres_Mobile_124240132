import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/series.dart';

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';

  /// Mengambil daftar semua show dari TVMaze
  static Future<List<Series>> fetchShows() async {
    final response = await http.get(Uri.parse('$baseUrl/shows'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => Series.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Gagal memuat daftar shows (Status: ${response.statusCode})');
    }
  }

  /// Mengambil detail TV show berdasarkan ID
  static Future<Series> fetchShowDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Series.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail show (Status: ${response.statusCode})');
    }
  }
}
