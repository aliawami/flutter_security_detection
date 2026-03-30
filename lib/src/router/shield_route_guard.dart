

// // shield_route_guard.dart

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../shield_result.dart';

// class FlutterShield {
//   static ShieldResult? _lastResult;

//   static Future<String?> routerRedirect(
//     BuildContext context,
//     GoRouterState state,
//   ) async {
//     _lastResult ??= await FlutterShield.check();

//     if (!_lastResult!.passed && 
//         state.uri.path != _config.blockedRoutePath) {
//       return _config.blockedRoutePath;
//     }
//     return null;
//   }
// }