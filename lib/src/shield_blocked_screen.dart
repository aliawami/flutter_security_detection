import 'package:flutter/widgets.dart';

/// Default screen shown by `ShieldGate` when the device fails the check.
///
/// Built from core widgets only, so it works in any app (Material, Cupertino
/// or custom) without depending on a design library.
class ShieldBlockedScreen extends StatelessWidget {
  const ShieldBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Explicit styles: without a Material ancestor, text would otherwise
    // inherit the framework's fallback style (yellow double underline).
    const title = TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
    );
    const message = TextStyle(
      color: Color(0x8AFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.none,
    );

    return ColoredBox(
      color: const Color(0xFF000000),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF44336),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Device Not Secure',
                textAlign: TextAlign.center,
                style: title,
              ),
              const SizedBox(height: 12),
              const Text(
                'This application cannot run on a compromised device.',
                textAlign: TextAlign.center,
                style: message,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
