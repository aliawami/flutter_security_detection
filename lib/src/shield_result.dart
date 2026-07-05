import 'package:freezed_annotation/freezed_annotation.dart';
import 'shield_threat.dart';

part 'shield_result.freezed.dart';

@freezed
abstract class ShieldResult with _$ShieldResult {
  const factory ShieldResult({
    required bool passed,
    required bool isJailbroken,
    required bool isRooted,
    required bool isFridaDetected,
    required List<ShieldThreat> threats,

    /// True when the security check itself could not run (native error or
    /// unsupported platform). `passed` is true in that case — the package
    /// fails open on internal errors — so consumers who want stricter
    /// behavior can inspect this flag and decide for themselves.
    @Default(false) bool checkFailed,
  }) = _ShieldResult;

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
}
