import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';
import 'dart:convert';

class StorageService {
  static const String _decksKey = 'decks';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<List<Deck>> getDecks() async {
    final String? decksJson = _prefs.getString(_decksKey);
    if (decksJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(decksJson);
    return decoded.map((json) => Deck.fromJson(json)).toList();
  }

  Future<void> saveDecks(List<Deck> decks) async {
    final String encoded = jsonEncode(decks.map((d) => d.toJson()).toList());
    await _prefs.setString(_decksKey, encoded);
  }
}

