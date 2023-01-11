import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Holds and saves all game data that needs persistence between launches.
class GameSave {
  static const moneyKey = 'money';
  static const highScoreKey = 'highScore';
  static const speedUpgradesKey = 'speedUpgrades';
  static const torqueUpgradesKey = 'torqueUpgrades';
  static const showControlsKey = 'showControls';

  final SharedPreferences _sharedPrefs;

  int _highScore = 0;
  int _money = 0;
  int _speedUpgrades = 0;
  int _torqueUpgrades = 0;
  bool _showControls = true;

  get money => _money;

  get highScore => _highScore;

  get speedUpgrades => _speedUpgrades;

  get torqueUpgrades => _torqueUpgrades;

  get showControls => _showControls;

  GameSave(SharedPreferences sharedPreferences)
      : _sharedPrefs = sharedPreferences {
    _money = _sharedPrefs.getInt(moneyKey) ?? 0;
    _highScore = _sharedPrefs.getInt(highScoreKey) ?? 0;
    _speedUpgrades = _sharedPrefs.getInt(speedUpgradesKey) ?? 0;
    _torqueUpgrades = _sharedPrefs.getInt(torqueUpgradesKey) ?? 0;
    _showControls = _sharedPrefs.getBool(showControlsKey) ?? true;
  }

  void addMoney(int moneyToAdd) =>
      _sharedPrefs.setInt(moneyKey, _money = max(0, _money + moneyToAdd));

  void updateHighScore(int score) =>
      _sharedPrefs.setInt(highScoreKey, _highScore = max(score, _highScore));

  void increaseSpeedUpgrades() => _sharedPrefs.setInt(
      speedUpgradesKey, _speedUpgrades = _speedUpgrades + 1);

  void increaseTorqueUpgrades() => _sharedPrefs.setInt(
      torqueUpgradesKey, _torqueUpgrades = _torqueUpgrades + 1);

  void invertShowControls() =>
      _sharedPrefs.setBool(showControlsKey, _showControls = !_showControls);

  void resetProgress() {
    _money = 0;
    _highScore = 0;
    _torqueUpgrades = 0;
    _speedUpgrades = 0;

    _sharedPrefs.clear();
  }
}
