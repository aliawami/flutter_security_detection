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
