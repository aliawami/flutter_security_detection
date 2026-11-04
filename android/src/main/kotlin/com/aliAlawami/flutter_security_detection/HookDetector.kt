package com.aliAlawami.flutter_security_detection

import android.content.Context
import android.content.pm.PackageManager
import android.os.Looper
import java.io.File

internal object HookDetector {

    private val XPOSED_FILES = listOf(
        "/system/framework/XposedBridge.jar",
        "/system/lib/libxposed_art.so",
        "/system/lib64/libxposed_art.so",
    )

    private val HOOK_PACKAGES = listOf(
        "de.robv.android.xposed.installer",   // Xposed
        "org.lsposed.manager",                 // LSPosed
        "org.meowcat.edxposed.manager",        // EdXposed
        "com.solohsu.android.edxp.manager",    // EdXposed (older)
        "org.lsposed.lspatch",                 // LSPatch
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

    // Check 1: Xposed files on disk, or the Xposed bridge class visible to
    // the system class loader (Xposed injects it into every process).
    private fun isXposedPresent(): Boolean {
        return XPOSED_FILES.any { path -> File(path).exists() } || isXposedClassLoadable()
    }

    private fun isXposedClassLoadable(): Boolean {
        return try {
            ClassLoader.getSystemClassLoader().loadClass("de.robv.android.xposed.XposedBridge")
            true
        } catch (e: Throwable) {
            false
        }
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

    // Check 4: Xposed leaves frames in the stack trace.
    // The checks run on a worker thread, whose own stack never contains
    // Xposed frames; those sit at the bottom of the main thread's stack
    // (ZygoteInit -> XposedBridge.main), so inspect that one too.
    private fun isXposedInStackTrace(): Boolean {
        return try {
            hasXposedFrame(Thread.currentThread().stackTrace) ||
                    hasXposedFrame(Looper.getMainLooper().thread.stackTrace) ||
                    hasXposedFrame(Throwable().stackTrace)
        } catch (e: Exception) {
            false
        }
    }

    internal fun hasXposedFrame(stack: Array<StackTraceElement>): Boolean {
        return stack.any { element ->
            element.className.contains("de.robv.android.xposed", ignoreCase = true) ||
                    element.className.contains("XposedBridge", ignoreCase = true)
        }
    }
}
