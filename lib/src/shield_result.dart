import 'package:flutter/foundation.dart';

import 'shield_threat.dart';

/// Outcome of a device integrity check.
@immutable
class ShieldResult {
  const ShieldResult({
    required this.passed,
    required this.isJailbroken,
    required this.isRooted,
    required this.isFridaDetected,
    required this.threats,

    /// True when the security check itself could not run (native error or
    /// unsupported platform). `passed` is true in that case — the package
    /// fails open on internal errors — so consumers who want stricter
    /// behavior can inspect this flag and decide for themselves.
    this.checkFailed = false,
  });

  /// A clean result, used by `devMode`.
  static const clean = ShieldResult(
    passed: true,
    isJailbroken: false,
    isRooted: false,
    isFridaDetected: false,
    threats: [],
  );

  factory ShieldResult.fromMap(Map<dynamic, dynamic> map) {
    final rawThreats = (map['threats'] as List<dynamic>?) ?? [];
    return ShieldResult(
      passed: map['passed'] as bool,
      isJailbroken: map['isJailbroken'] as bool,
      isRooted: map['isRooted'] as bool,
      isFridaDetected: map['isFridaDetected'] as bool,
      threats:
          rawThreats.map((t) => ShieldThreat.fromString(t as String)).toList(),
    );
  }

  final bool passed;
  final bool isJailbroken;
  final bool isRooted;
  final bool isFridaDetected;
  final List<ShieldThreat> threats;
  final bool checkFailed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShieldResult &&
          passed == other.passed &&
          isJailbroken == other.isJailbroken &&
          isRooted == other.isRooted &&
          isFridaDetected == other.isFridaDetected &&
          checkFailed == other.checkFailed &&
          listEquals(threats, other.threats);

  @override
  int get hashCode => Object.hash(
        passed,
        isJailbroken,
        isRooted,
        isFridaDetected,
        checkFailed,
        Object.hashAll(threats),
      );

  @override
  String toString() => 'ShieldResult(passed: $passed, '
      'isJailbroken: $isJailbroken, isRooted: $isRooted, '
      'isFridaDetected: $isFridaDetected, threats: $threats, '
      'checkFailed: $checkFailed)';
}
