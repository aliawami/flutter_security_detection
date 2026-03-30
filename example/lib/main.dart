import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterSecurityDetection.init(
    config: ShieldConfig(
      devMode: kDebugMode,
      onThreatDetected: (result) {
        debugPrint('Threats: ${result.threats}');
      },
    ),
  );

  runApp(const ExampleApp());
}

final _router = GoRouter(
  redirect: FlutterSecurityDetection.routerRedirect,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    FlutterSecurityDetection.blockedRoute,
  ],
);

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ShieldResult? _result;
  bool _loading = false;

  Future<void> _runCheck() async {
    setState(() => _loading = true);
    final result = await FlutterSecurityDetection.recheck();
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Shield Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _runCheck,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Run Security Check'),
            ),
            const SizedBox(height: 24),
            if (_result != null) ...[
              _StatusRow('Passed', _result!.passed),
              _StatusRow('Jailbroken', _result!.isJailbroken),
              _StatusRow('Rooted', _result!.isRooted),
              _StatusRow('Frida Detected', _result!.isFridaDetected),
              const SizedBox(height: 16),
              const Text(
                'Threats:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_result!.threats.isEmpty)
                const Text('None — device is clean')
              else
                ..._result!.threats.map(
                  (t) => Text(
                    '• ${t.name}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool value;

  const _StatusRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
