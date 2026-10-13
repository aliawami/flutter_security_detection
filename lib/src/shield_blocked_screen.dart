import 'package:flutter/material.dart';

/// Default screen shown by `ShieldGate` when the device fails the check.
class ShieldBlockedScreen extends StatelessWidget {
  const ShieldBlockedScreen({super.key});

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
