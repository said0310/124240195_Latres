import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

class FavoriteStore extends ChangeNotifier {
  static final FavoriteStore instance = FavoriteStore._internal();
  FavoriteStore._internal();

  int? _userId;
  final List<Character> _favorites = [];

  List<Character> get favorites => List.unmodifiable(_favorites);

  String get _storageKey =>
      _userId != null ? 'favorites_$_userId' : 'favorites_default';

  Future<void> init(int? userId) async {
    _userId = userId;
    _favorites.clear();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? [];

    for (final item in list) {
      try {
        final map = json.decode(item) as Map<String, dynamic>;
        _favorites.add(Character.fromJson(map));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    notifyListeners();
  }

  bool isFavorite(int characterId) {
    return _favorites.any((c) => c.id == characterId);
  }

  Future<bool> toggleFavorite(Character character) async {
    final index = _favorites.indexWhere((c) => c.id == character.id);
    final bool added;

    if (index >= 0) {
      _favorites.removeAt(index);
      added = false;
    } else {
      _favorites.add(character);
      added = true;
    }

    await _persist();
    notifyListeners();
    return added;
  }

  Future<void> removeFavorite(int characterId) async {
    _favorites.removeWhere((c) => c.id == characterId);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = _favorites.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_storageKey, stringList);
  }
}
