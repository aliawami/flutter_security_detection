package com.aliAlawami.flutter_security_detection

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

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
        if (canExecuteSuCommand()) threats.add("su_command_executed")

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
        return try {
            DANGEROUS_PROPS.any { (prop, dangerousValue) ->
                val process = Runtime.getRuntime().exec("getprop $prop")
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                val value = reader.readLine()?.trim()
                value == dangerousValue
            }
        } catch (e: Exception) {
            false
        }
    }

    // Check 5: Can actually run su — strongest signal
    private fun canExecuteSuCommand(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readLine()
            output?.contains("uid=0") == true
        } catch (e: Exception) {
            false
        }
    }
}