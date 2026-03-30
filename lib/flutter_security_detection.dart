import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'src/flutter_security_detection_channel.dart';
import 'src/shield_config.dart';
import 'src/shield_result.dart';
export 'src/shield_threat.dart';
export 'src/shield_config.dart';
export 'src/shield_result.dart';

class FlutterSecurityDetection {
  static ShieldConfig _config = const ShieldConfig();
  static ShieldResult? _cachedResult;

  /// Initialize once — typically in main() before runApp()
  static Future<void> init({ShieldConfig config = const ShieldConfig()}) async {
    _config = config;

    // devMode bypasses all native checks
    if (_config.devMode) {
      _cachedResult = const ShieldResult(
        passed: true,
        isJailbroken: false,
        isRooted: false,
        isFridaDetected: false,
        threats: [],
      );
      debugPrint('⚠️ FlutterShield: devMode is ON — all checks bypassed');
      return;
    }

    _cachedResult = await FlutterSecurityDetectionChannel.checkDevice(_config);
    if (!_cachedResult!.passed) {
      _config.onThreatDetected?.call(_cachedResult!);
    }
  }

  /// Manual check — returns cached result if already checked
  static Future<ShieldResult> check() async {
    // Respect devMode even if check() is called directly
    if (_config.devMode) {
      return const ShieldResult(
        passed: true,
        isJailbroken: false,
        isRooted: false,
        isFridaDetected: false,
        threats: [],
      );
    }

    _cachedResult ??= await FlutterSecurityDetectionChannel.checkDevice(_config);
    return _cachedResult!;
  }

  /// Force a fresh check — ignores cache
  static Future<ShieldResult> recheck() async {
    if (_config.devMode) {
      return const ShieldResult(
        passed: true,
        isJailbroken: false,
        isRooted: false,
        isFridaDetected: false,
        threats: [],
      );
    }
    _cachedResult = await FlutterSecurityDetectionChannel.checkDevice(_config);
    return _cachedResult!;
  }

  /// go_router redirect — plug directly into GoRouter
  static Future<String?> routerRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final result = await check();

    if (!result.passed && state.uri.path != _config.blockedRoutePath) {
      return _config.blockedRoutePath;
    }
    return null;
  }

  /// Pre-built blocked route for go_router routes list
  static GoRoute get blockedRoute => GoRoute(
        path: _config.blockedRoutePath,
        builder: (context, state) =>
            _config.blockedWidget ?? const _DefaultBlockedScreen(),
      );
}

class _DefaultBlockedScreen extends StatelessWidget {
  const _DefaultBlockedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, color: Colors.red, size: 72),
            const SizedBox(height: 24),
            Text(
              'Device Not Secure',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'This application cannot run on a compromised device.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
