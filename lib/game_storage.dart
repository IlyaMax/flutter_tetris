import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

const _recordKey = '_secondsKey';

class GameStorage {
  final SharedPreferences _pref;

  GameStorage(this._pref);
  int? get record => _pref.getInt(_recordKey);
  Future<void> saveRecord(int newRecord) => _pref.setInt(
      _recordKey, record == null ? newRecord : max(record!, newRecord));
}
