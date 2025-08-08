import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> saveLastSection(int value) async {
    (await _prefs).setInt('last_section', value);
  }

  static Future<int> getLastSection() async {
    return (await _prefs).getInt('last_section') ?? 0;
  }
  // Save and get isGrid
  static Future<void> saveIsGrid(bool value) async {
    (await _prefs).setBool('is_grid', value);
  }

  static Future<bool> getIsGrid() async {
    return (await _prefs).getBool('is_grid') ?? false;
  }

  // Save and get gridCount
  static Future<void> saveGridCount(int value) async {
    (await _prefs).setInt('grid_count', value);
  }

  static Future<int> getGridCount() async {
    return (await _prefs).getInt('grid_count') ?? 2;
  }

  // Save and get sortType
  static Future<void> saveSortType(String value) async {
    (await _prefs).setString('sort_type', value);
  }

  static Future<String> getSortType() async {
    return (await _prefs).getString('sort_type') ?? 'name';
  }

  // Save and get isVertical
  static Future<void> saveIsVertical(bool value) async {
    (await _prefs).setBool('is_vertical', value);
  }

  static Future<bool> getIsVertical() async {
    return (await _prefs).getBool('is_vertical') ?? true; // default true
  }

  // Save and get isContinuous
  static Future<void> saveIsContinuous(bool value) async {
    (await _prefs).setBool('is_continuous', value);
  }

  static Future<bool> getIsContinuous() async {
    return (await _prefs).getBool('is_continuous') ?? true; // default true
  }

  // Save and get isDark
  static Future<void> saveIsDark(bool value) async {
    (await _prefs).setBool('is_dark', value);
  }

  static Future<bool> getIsDark() async {
    return (await _prefs).getBool('is_dark') ?? false; // default false
  }

  static Future<void> saveIsYellow(bool value) async {
    (await _prefs).setBool('is_yellow', value);
  }

  static Future<bool> getIsYellow() async {
    return (await _prefs).getBool('is_yellow') ?? false; // default false
  }

  static Future<void> saveIsLTR(bool value) async {
    (await _prefs).setBool('is_LTR', value);
  }

  static Future<bool> getIsLTR() async {
    return (await _prefs).getBool('is_LTR') ?? false; // default false
  }

  static Future<void> saveRenderingQuality(int value) async {
    (await _prefs).setInt('rendering_quality', value);
  }

  static Future<int> getRenderingQuality() async {
    return (await _prefs).getInt('rendering_quality') ?? 2;
  }

  // Retrieve all settings
  static Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'isGrid': await getIsGrid(),
      'gridCount': await getGridCount(),
      'sortType': await getSortType(),
      'isVertical': await getIsVertical(),
      'isContinuous': await getIsContinuous(),
      'isDark': await getIsDark(),
      'isYellow': await getIsYellow(),
      'isLTR': await getIsLTR(),
      'renderingQuality': await getRenderingQuality(),

    };
  }

  // Load settings backup
  static Future<void> loadBackup(Map<String, dynamic> settings) async {
    await saveIsGrid(settings['isGrid'] ?? true);
    await saveGridCount(settings['gridCount'] ?? 3);
    await saveSortType(settings['sortType'] ?? 'alphabetical');
    await saveIsVertical(settings['isVertical'] ?? true);
    await saveIsContinuous(settings['isContinuous'] ?? true);
    await saveIsDark(settings['isDark'] ?? false);
    await saveIsYellow(settings['isYellow'] ?? false);
    await saveIsYellow(settings['isLTR'] ?? true);
    await saveRenderingQuality(settings['renderingQuality'] ?? 2);
  }
}
