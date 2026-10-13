import 'package:flutter/widgets.dart';

import '../flutter_security_detection.dart';

/// Shows [child] only while the device passes the security check.
///
/// Router-agnostic: wrap your app (or any subtree) in it. It rebuilds when a
/// runtime re-check changes the outcome. While the first check is still
/// running, [loading] is shown instead of [child], so protected UI never
/// flashes on a compromised device.
class ShieldGate extends StatefulWidget {
  const ShieldGate({
    super.key,
    required this.child,
    this.blocked,
    this.loading = const SizedBox.shrink(),
  });

  final Widget child;

  /// Shown when the check fails. Defaults to [ShieldBlockedScreen].
  final Widget? blocked;

  /// Shown until the first result is available.
  final Widget loading;

  @override
  State<ShieldGate> createState() => _ShieldGateState();
}

class _ShieldGateState extends State<ShieldGate> {
  @override
  void initState() {
    super.initState();
    // Make sure a check is running if init() was not awaited before runApp.
    FlutterSecurityDetection.check();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ShieldResult?>(
      valueListenable: FlutterSecurityDetection.resultListenable,
      builder: (context, result, _) {
        if (result == null) return widget.loading;
        if (!result.passed) {
          return widget.blocked ?? const ShieldBlockedScreen();
        }
        return widget.child;
      },
    );
  }
}
