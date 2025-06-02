import 'dart:convert';

import 'package:delve/Character/character.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterRepository {
  static const _key = 'saved_party';

  Future<void> saveParty(List<Character> party) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = party.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<Character>> loadParty() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Character.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSavedParty() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
