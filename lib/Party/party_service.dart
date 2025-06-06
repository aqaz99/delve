import 'dart:convert';

import 'package:delve/Character/character.dart';
import 'package:delve/Dungeon/dungeon_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartyService {
  static const _key = 'saved_party';
  static const _delveKey = 'delve_state';

  Future<void> clearDelveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_delveKey);
  }

  PartyService();

  Future<void> saveParty(List<Character> party) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = party.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<Character>> loadParty() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      List<Character> newParty = getThreeRandomCharacters();
      saveParty(newParty);
      return newParty;
    }

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

  Future<void> saveDelveState(DelveState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_delveKey, jsonEncode(state.toJson()));
  }

  Future<DelveState?> loadDelveState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_delveKey);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DelveState.fromJson(json);
    } catch (e) {
      print('Error loading delve state: $e');
      return null;
    }
  }
}
