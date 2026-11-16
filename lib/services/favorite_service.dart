import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/series.dart';

class FavoriteService {
  static const String boxName = 'favorite_shows';

  static Box get _box => Hive.box(boxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static ValueListenable<Box> listenable() {
    return _box.listenable();
  }

  static bool isFavorite(int id) {
    return _box.containsKey(id);
  }

  static Future<void> addFavorite(Series series) async {
    await _box.put(series.id, series.toMap());
  }

  static Future<void> removeFavorite(int id) async {
    await _box.delete(id);
  }

  static Future<bool> toggleFavorite(Series series) async {
    if (isFavorite(series.id)) {
      await removeFavorite(series.id);
      return false; // Removed
    } else {
      await addFavorite(series);
      return true; // Added
    }
  }

  static List<Series> getFavorites() {
    final List<Series> list = [];
    for (var i = 0; i < _box.length; i++) {
      final item = _box.getAt(i);
      if (item is Map) {
        list.add(Series.fromMap(item));
      }
    }
    return list;
  }
}
