import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class CharacterResponse {
  final List<Character> characters;
  final bool hasNext;

  const CharacterResponse({required this.characters, required this.hasNext});
}

class EpisodeResponse {
  final List<Episode> episodes;
  final bool hasNext;

  const EpisodeResponse({required this.episodes, required this.hasNext});
}

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  static Future<CharacterResponse> getCharacters({
    int page = 1,
    String? status,
    String? name,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }

    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List? ?? [])
            .map((item) => Character.fromJson(item as Map<String, dynamic>))
            .toList();
        final info = data['info'] as Map<String, dynamic>?;
        final hasNext = info != null && info['next'] != null;
        return CharacterResponse(characters: results, hasNext: hasNext);
      } else if (response.statusCode == 404) {
        // 404 from Rick and Morty API means no matches found for search/filter query
        return const CharacterResponse(characters: [], hasNext: false);
      } else {
        throw Exception('Server mengembalikan kode status: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Gagal terhubung ke jaringan. Periksa koneksi internet Anda.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Silakan coba beberapa saat lagi.');
      }
      rethrow;
    }
  }

  static Future<Character> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');

    try {
      final response = await http.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Character.fromJson(data);
      } else {
        throw Exception('Karakter tidak ditemukan (${response.statusCode})');
      }
    } on http.ClientException {
      throw Exception('Gagal terhubung ke jaringan. Periksa koneksi internet Anda.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Silakan coba lagi.');
      }
      rethrow;
    }
  }

  static Future<EpisodeResponse> getEpisodes({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/episode?page=$page');

    try {
      final response = await http.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List? ?? [])
            .map((item) => Episode.fromJson(item as Map<String, dynamic>))
            .toList();
        final info = data['info'] as Map<String, dynamic>?;
        final hasNext = info != null && info['next'] != null;
        return EpisodeResponse(episodes: results, hasNext: hasNext);
      } else if (response.statusCode == 404) {
        return const EpisodeResponse(episodes: [], hasNext: false);
      } else {
        throw Exception('Gagal memuat episode (${response.statusCode})');
      }
    } on http.ClientException {
      throw Exception('Gagal terhubung ke jaringan. Periksa koneksi internet Anda.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Silakan coba lagi.');
      }
      rethrow;
    }
  }
}
