import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'src/flutter_security_detection_channel.dart';
import 'src/shield_config.dart';
import 'src/shield_result.dart';

export 'src/shield_blocked_screen.dart';
export 'src/shield_config.dart';
export 'src/shield_gate.dart';
export 'src/shield_result.dart';
export 'src/shield_threat.dart';

/// Client-side device integrity checks.
///
/// These checks run on a device the attacker controls and can be bypassed by
/// a determined attacker. Treat them as a deterrent and a UX layer, and
/// enforce anything that matters on your server.
class FlutterSecurityDetection {
  FlutterSecurityDetection._();

  static ShieldConfig _config = const ShieldConfig();
  static final ValueNotifier<ShieldResult?> _result = ValueNotifier(null);
  static Future<ShieldResult>? _inFlight;
  static _ResumeObserver? _observer;
  static Timer? _timer;

  /// The latest result, or null before the first check completes. Listen to
  /// it to react when a runtime re-check changes the outcome (for example as
  /// a `refreshListenable` of your router).
  static ValueListenable<ShieldResult?> get resultListenable => _result;

  /// The latest result, or null before the first check completes.
  static ShieldResult? get lastResult => _result.value;

  /// True when the latest result is a failing one. False before the first
  /// check completes — use [ShieldGate] or await [init] to avoid that gap.
  static bool get isBlocked => _result.value?.passed == false;

  /// Initialize once — typically in main() before runApp().
  static Future<void> init({ShieldConfig config = const ShieldConfig()}) async {
    _stopRuntimeChecks();
    _config = config;
    _result.value = null;

    // devMode bypasses all native checks
    if (_config.devMode) {
      _result.value = ShieldResult.clean;
      debugPrint('⚠️ FlutterSecurityDetection: devMode is ON — '
          'all checks bypassed');
      return;
    }

    await _runCheck();
    _startRuntimeChecks();
  }

  /// Manual check — returns the latest result if one exists.
  static Future<ShieldResult> check() async {
    final current = _result.value;
    if (current != null) return current;
    return _runCheck();
  }

  /// Force a fresh check — ignores the cached result.
  static Future<ShieldResult> recheck() => _runCheck();

  // Deduplicates concurrent callers so only one native check runs; everyone
  // awaits the same future.
  static Future<ShieldResult> _runCheck() {
    if (_config.devMode) return Future.value(ShieldResult.clean);
    final config = _config;
    return _inFlight ??= () async {
      try {
        final result =
            await FlutterSecurityDetectionChannel.checkDevice(config);
        _publish(result, config);
        return result;
      } finally {
        _inFlight = null;
      }
    }();
  }

  static void _publish(ShieldResult result, ShieldConfig config) {
    final changed = _result.value != result;
    _result.value = result;
    if (changed && !result.passed) config.onThreatDetected?.call(result);
  }

  static void _startRuntimeChecks() {
    if (_config.recheckOnResume) {
      _observer = _ResumeObserver(() => unawaited(_runCheck()));
      WidgetsBinding.instance.addObserver(_observer!);
    }
    final interval = _config.recheckInterval;
    if (interval != null) {
      _timer = Timer.periodic(interval, (_) => unawaited(_runCheck()));
    }
  }

  static void _stopRuntimeChecks() {
    final observer = _observer;
    if (observer != null) WidgetsBinding.instance.removeObserver(observer);
    _observer = null;
    _timer?.cancel();
    _timer = null;
  }

  /// Stops runtime re-checks and clears state. For tests.
  @visibleForTesting
  static void reset() {
    _stopRuntimeChecks();
    _config = const ShieldConfig();
    _inFlight = null;
    _result.value = null;
  }
}

class _ResumeObserver with WidgetsBindingObserver {
  _ResumeObserver(this._onResume);

  final VoidCallback _onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }
}
