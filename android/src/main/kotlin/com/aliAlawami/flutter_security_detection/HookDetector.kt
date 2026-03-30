package com.aliAlawami.flutter_security_detection

import android.content.Context
import android.content.pm.PackageManager
import java.io.File

internal object HookDetector {

    private val XPOSED_FILES = listOf(
        "/system/framework/XposedBridge.jar",
        "/system/lib/libxposed_art.so",
        "/system/lib64/libxposed_art.so",
        "/data/data/de.robv.android.xposed.installer",
    )

    private val HOOK_PACKAGES = listOf(
        "de.robv.android.xposed.installer",   // Xposed
        "org.lsposed.manager",                 // LSPosed
        "com.saurik.substrate",                // Substrate
        "com.zachspong.temprootremovejb",
        "com.amphoras.hidemyroot",
    )

    fun isHookFrameworkDetected(context: Context): Pair<Boolean, List<String>> {
        val threats = mutableListOf<String>()

        if (isXposedPresent()) threats.add("xposed_framework_found")
        if (isLSPosedPresent(context)) threats.add("lsposed_found")
        if (isHookPackageInstalled(context)) threats.add("hook_package_found")
        if (isXposedInStackTrace()) threats.add("xposed_stack_trace")

        return Pair(threats.isNotEmpty(), threats)
    }

    // Check 1: Xposed files on disk
    private fun isXposedPresent(): Boolean {
        return XPOSED_FILES.any { path -> File(path).exists() }
    }

    // Check 2: LSPosed manager package
    private fun isLSPosedPresent(context: Context): Boolean {
        return try {
            context.packageManager.getPackageInfo(
                "org.lsposed.manager",
                PackageManager.GET_ACTIVITIES
            )
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    // Check 3: Any known hook management package
    private fun isHookPackageInstalled(context: Context): Boolean {
        val pm = context.packageManager
        return HOOK_PACKAGES.any { pkg ->
            try {
                pm.getPackageInfo(pkg, PackageManager.GET_ACTIVITIES)
                true
            } catch (e: PackageManager.NameNotFoundException) {
                false
            }
        }
    }

    // Check 4: Xposed leaves traces in the stack trace
    // This works even when file-based checks are hidden by Magisk
    private fun isXposedInStackTrace(): Boolean {
        return try {
            throw Exception("shield_probe")
        } catch (e: Exception) {
            e.stackTrace.any { element ->
                element.className.contains("de.robv.android.xposed", ignoreCase = true) ||
                element.className.contains("XposedBridge", ignoreCase = true)
            }
        }
    }
}