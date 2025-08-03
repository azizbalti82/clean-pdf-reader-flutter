import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static Future<void> saveIsGrid(bool value) async {
    (await _prefs).setBool('is_grid', value);
  }

  static Future<bool> getIsGrid() async {
    return (await _prefs).getBool('is_grid') ?? false;
  }

  static Future<void> saveGridCount(int value) async {
    (await _prefs).setInt('grid_count', value);
  }

  static Future<int> getGridCount() async {
    return (await _prefs).getInt('grid_count') ?? 2;
  }

  static Future<void> saveSortType(String value) async {
    (await _prefs).setString('sort_type', value);
  }

  static Future<String> getSortType() async {
    return (await _prefs).getString('sort_type') ?? 'name';
  }

  static Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'isGrid': await getIsGrid(),
      'gridCount': await getGridCount(),
      'sortType': await getSortType(),
    };
  }

  static Future<void> loadBackup(Map<String, dynamic> settings) async {
    await saveIsGrid(settings['isGrid'] ?? true);
    await saveGridCount(settings['gridCount'] ?? 3);
    await saveSortType(settings['sortType'] ?? 'alphabetical');
  }
}
