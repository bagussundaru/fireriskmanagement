import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class LocalStorageService {
  static const String _draftsKey = 'fire_risk_drafts';

  static Future<List<Assessment>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getStringList(_draftsKey) ?? [];
    
    return draftsJson.map((jsonStr) {
      final map = json.decode(jsonStr);
      return Assessment.fromJson(map);
    }).toList();
  }

  static Future<void> saveDraft(Assessment draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    
    // Remove if exists to update
    drafts.removeWhere((element) => element.id == draft.id);
    drafts.add(draft);
    
    final draftsJson = drafts.map((d) => json.encode(d.toJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }

  static Future<void> deleteDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    
    drafts.removeWhere((element) => element.id == id);
    
    final draftsJson = drafts.map((d) => json.encode(d.toJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }
}
