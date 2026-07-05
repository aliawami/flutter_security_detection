package com.aliAlawami.flutter_security_detection

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.File

internal object RootDetector {

    private val SU_PATHS = listOf(
        "/system/bin/su",
        "/system/xbin/su",
        "/sbin/su",
        "/system/su",
        "/system/bin/.ext/.su",
        "/system/usr/we-need-root/su-backup",
        "/data/local/xbin/su",
        "/data/local/bin/su",
        "/data/local/su",
    )

    private val ROOT_PACKAGES = listOf(
        "com.topjohnwu.magisk",
        "com.kingroot.kinguser",
        "com.koushikdutta.superuser",
        "eu.chainfire.supersu",
        "com.noshufou.android.su",
        "com.thirdparty.superuser",
        "com.yellowes.su",
    )

    private val DANGEROUS_PROPS = mapOf(
        "ro.debuggable" to "1",
        "ro.secure" to "0",
    )

    fun isRooted(context: Context): Pair<Boolean, List<String>> {
        val threats = mutableListOf<String>()

        if (isSuBinaryPresent()) threats.add("su_binary_found")
        if (isRootPackageInstalled(context)) threats.add("root_app_found")
        if (hasTestKeys()) threats.add("test_keys_found")
        if (hasDangerousProps()) threats.add("dangerous_props_found")
        // Executing `su -c id` was removed in 0.2.0: it popped a superuser
        // grant dialog on rooted users' devices and could block ~10s.
        // The su binary file check above covers the same signal passively.

        return Pair(threats.isNotEmpty(), threats)
    }

    // Check 1: su binary in common locations
    private fun isSuBinaryPresent(): Boolean {
        return SU_PATHS.any { path -> File(path).exists() }
    }

    // Check 2: Known root management apps installed
    private fun isRootPackageInstalled(context: Context): Boolean {
        val pm = context.packageManager
        return ROOT_PACKAGES.any { pkg ->
            try {
                pm.getPackageInfo(pkg, PackageManager.GET_ACTIVITIES)
                true
            } catch (e: PackageManager.NameNotFoundException) {
                false
            }
        }
    }

    // Check 3: Build signed with test keys
    private fun hasTestKeys(): Boolean {
        val buildTags = Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }

    // Check 4: Dangerous system properties
    private fun hasDangerousProps(): Boolean {
        return DANGEROUS_PROPS.any { (prop, dangerousValue) ->
            readSystemProperty(prop) == dangerousValue
        }
    }

    private fun readSystemProperty(prop: String): String? {
        var process: Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("getprop", prop))
            process.inputStream.bufferedReader().use { it.readLine()?.trim() }
        } catch (e: Exception) {
            null
        } finally {
            process?.destroy()
        }
    }
}