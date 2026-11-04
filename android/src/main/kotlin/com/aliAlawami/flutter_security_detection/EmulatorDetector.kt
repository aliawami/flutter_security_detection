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

    // Check 1: Build properties that only appear on emulators.
    // Deliberately NOT included: a "test-keys" fingerprint (custom ROMs;
    // reported separately as test_keys_found) and an "unknown" fingerprint
    // prefix (seen on real devices).
    private fun hasSuspiciousBuildProps(): Boolean = matchesEmulatorBuild(
        fingerprint = Build.FINGERPRINT,
        model = Build.MODEL,
        manufacturer = Build.MANUFACTURER,
        brand = Build.BRAND,
        device = Build.DEVICE,
        product = Build.PRODUCT,
        hardware = Build.HARDWARE,
    )

    internal fun matchesEmulatorBuild(
        fingerprint: String?,
        model: String?,
        manufacturer: String?,
        brand: String?,
        device: String?,
        product: String?,
        hardware: String?,
    ): Boolean {
        fun String?.has(s: String) = this?.contains(s, ignoreCase = true) == true
        fun String?.starts(s: String) = this?.startsWith(s) == true
        return fingerprint.starts("generic") ||
                fingerprint.has("vbox") ||
                model.has("Emulator") ||
                model.has("Android SDK built for x86") ||
                manufacturer.has("Genymotion") ||
                brand.starts("generic") ||
                device.starts("generic") ||
                product.has("sdk_gphone") ||
                product.has("vbox") ||
                product.has("emulator") ||
                hardware.has("goldfish") ||
                hardware.has("ranchu") ||
                hardware.has("vbox86")
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

    // Check 4: Emulator-specific hardware identifiers.
    // An empty radio version is deliberately NOT treated as a signal —
    // real Wi-Fi-only devices (tablets without cellular) have no baseband
    // and would be false-positived as emulators.
    private fun hasEmulatorHardware(): Boolean {
        val hardware = Build.HARDWARE
        return hardware.contains("goldfish", ignoreCase = true) ||
                hardware.contains("ranchu", ignoreCase = true) ||
                hardware.contains("vbox86", ignoreCase = true)
    }
}