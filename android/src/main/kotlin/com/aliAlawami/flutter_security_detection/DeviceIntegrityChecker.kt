package com.aliAlawami.flutter_security_detection

import android.content.Context
import android.content.pm.ApplicationInfo
import android.provider.Settings

internal object DeviceIntegrityChecker {

    fun check(
        context: Context,
        enableFrida: Boolean,
        enableRoot: Boolean,
        enableEmulator: Boolean,
        enableHookDetection: Boolean,
        enableDebugDetection: Boolean,
    ): Map<String, Any> {
        val allThreats = mutableListOf<String>()
        var isFridaDetected = false
        var isRooted = false

        if (enableFrida) {
            val (detected, threats) = FridaDetector.isFridaDetected()
            isFridaDetected = detected
            allThreats.addAll(threats)
        }

        if (enableRoot) {
            val (rooted, threats) = RootDetector.isRooted(context)
            isRooted = rooted
            allThreats.addAll(threats)
        }

        if (enableEmulator) {
            val (detected, threats) = EmulatorDetector.isEmulator(context)
            allThreats.addAll(threats)
        }

        if (enableHookDetection) {
            val (detected, threats) = HookDetector.isHookFrameworkDetected(context)
            allThreats.addAll(threats)
        }

        if (enableDebugDetection) {
            if (isDebuggable(context)) allThreats.add("debug_mode_enabled")
            if (isAdbEnabled(context)) allThreats.add("adb_enabled")
        }

        return mapOf(
            "passed" to allThreats.isEmpty(),
            "isJailbroken" to false,
            "isRooted" to isRooted,
            "isFridaDetected" to isFridaDetected,
            "threats" to allThreats,
        )
    }

    // Checks ApplicationInfo flags — cannot be spoofed from Dart
    private fun isDebuggable(context: Context): Boolean {
        return (context.applicationInfo.flags
                and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    // ADB enabled is a moderate signal in production devices
    private fun isAdbEnabled(context: Context): Boolean {
        return Settings.Global.getInt(
            context.contentResolver,
            Settings.Global.ADB_ENABLED,
            0
        ) == 1
    }
}