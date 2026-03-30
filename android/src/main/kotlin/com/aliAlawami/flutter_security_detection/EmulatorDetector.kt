package com.aliAlawami.flutter_security_detection

import android.content.Context
import android.os.Build
import android.provider.Settings
import java.io.File

internal object EmulatorDetector {

    private val EMULATOR_FILES = listOf(
        "/dev/socket/qemud",
        "/dev/qemu_pipe",
        "/system/lib/libc_malloc_debug_qemu.so",
        "/sys/qemu_trace",
        "/system/bin/qemu-props",
        "/dev/socket/genyd",
        "/dev/socket/baseband_genyd",
    )

    private val EMULATOR_PACKAGES = listOf(
        "com.google.android.launcher.layouts.genymotion",
        "com.bluestacks",
        "com.bignox.app",
        "com.vphone.launcher",
    )

    fun isEmulator(context: Context): Pair<Boolean, List<String>> {
        val threats = mutableListOf<String>()

        if (hasSuspiciousBuildProps()) threats.add("emulator_build_props")
        if (hasEmulatorFiles()) threats.add("emulator_files_found")
        if (isEmulatorPackageInstalled(context)) threats.add("emulator_package_found")
        if (hasEmulatorHardware()) threats.add("emulator_hardware_found")

        return Pair(threats.isNotEmpty(), threats)
    }

    // Check 1: Build properties that only appear on emulators
    private fun hasSuspiciousBuildProps(): Boolean {
        val suspiciousConditions = listOf(
            Build.FINGERPRINT.startsWith("generic"),
            Build.FINGERPRINT.startsWith("unknown"),
            Build.FINGERPRINT.contains("vbox"),
            Build.FINGERPRINT.contains("test-keys"),
            Build.MODEL.contains("Emulator", ignoreCase = true),
            Build.MODEL.contains("Android SDK built for x86", ignoreCase = true),
            Build.MANUFACTURER.contains("Genymotion", ignoreCase = true),
            Build.BRAND.startsWith("generic"),
            Build.DEVICE.startsWith("generic"),
            Build.PRODUCT.contains("sdk_gphone", ignoreCase = true),
            Build.PRODUCT.contains("vbox", ignoreCase = true),
            Build.PRODUCT.contains("emulator", ignoreCase = true),
            Build.HARDWARE.contains("goldfish", ignoreCase = true),
            Build.HARDWARE.contains("ranchu", ignoreCase = true),
            Build.HARDWARE.contains("vbox86", ignoreCase = true),
        )
        return suspiciousConditions.any { it }
    }

    // Check 2: Emulator-specific files on disk
    private fun hasEmulatorFiles(): Boolean {
        return EMULATOR_FILES.any { path -> File(path).exists() }
    }

    // Check 3: Known emulator launcher packages
    private fun isEmulatorPackageInstalled(context: Context): Boolean {
        val pm = context.packageManager
        return EMULATOR_PACKAGES.any { pkg ->
            try {
                pm.getPackageInfo(pkg, 0)
                true
            } catch (e: Exception) {
                false
            }
        }
    }

    // Check 4: Emulator-specific hardware identifiers
    private fun hasEmulatorHardware(): Boolean {
        val radio = Build.getRadioVersion()
        val hardware = Build.HARDWARE

        return radio.isNullOrEmpty() ||
                hardware.contains("goldfish", ignoreCase = true) ||
                hardware.contains("ranchu", ignoreCase = true)
    }
}