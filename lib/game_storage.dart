import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

const _secondsKey = '_secondsKey';

class GameStorage {
  final SharedPreferences _pref;

  GameStorage(this._pref);
  int? get record => _pref.getInt(_secondsKey);
  Future<void> saveRecord(int seconds) => _pref.setInt(
      _secondsKey, record == null ? seconds : max(record!, seconds));
}
