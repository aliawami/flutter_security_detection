package com.aliAlawami.flutter_security_detection

import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.net.Socket

internal object FridaDetector {

    private const val FRIDA_PORT = 27042
    private const val FRIDA_SERVER_PROCESS = "frida-server"

    private val FRIDA_LIBRARIES = listOf(
        "frida-agent",
        "frida-gadget",
        "frida",
    )

    private val FRIDA_FILES = listOf(
        "/data/local/tmp/frida-server",
        "/data/local/tmp/re.frida.server",
    )

    fun isFridaDetected(): Pair<Boolean, List<String>> {
        val threats = mutableListOf<String>()

        if (isFridaPortOpen()) threats.add("frida_port_open")
        if (isFridaProcessRunning()) threats.add("frida_process_found")
        if (isFridaLibraryLoaded()) threats.add("frida_library_found")
        if (isFridaFilePresent()) threats.add("frida_file_found")

        return Pair(threats.isNotEmpty(), threats)
    }

    // Check 1: Frida server default port
    private fun isFridaPortOpen(): Boolean {
        return try {
            val socket = Socket("127.0.0.1", FRIDA_PORT)
            socket.close()
            true
        } catch (e: Exception) {
            false
        }
    }

    // Check 2: Frida server in running processes
private fun isFridaProcessRunning(): Boolean {
    // Note: Process scanning is restricted by Android's process
    // namespace isolation on Android 7+. This check works on
    // devices where the app has elevated access but is intentionally
    // best-effort. Port and file detection are the primary Frida signals.
    return try {
        File("/proc").listFiles()?.any { procDir ->
            if (procDir.isDirectory && procDir.name.all { it.isDigit() }) {
                val cmdlineFile = File(procDir, "cmdline")
                if (cmdlineFile.exists()) {
                    val cmdline = cmdlineFile.readBytes()
                        .map { if (it == 0.toByte()) ' ' else it.toInt().toChar() }
                        .joinToString("")
                        .trim()
                    cmdline.contains(FRIDA_SERVER_PROCESS, ignoreCase = true) ||
                    cmdline.contains("frida", ignoreCase = true)
                } else false
            } else false
        } ?: false
    } catch (e: Exception) {
        false
    }
}





    // Check 3: Frida agent loaded in memory maps
    private fun isFridaLibraryLoaded(): Boolean {
        return try {
            val mapsFile = File("/proc/self/maps")
            if (!mapsFile.exists()) return false
            mapsFile.readLines().any { line ->
                FRIDA_LIBRARIES.any { lib ->
                    line.contains(lib, ignoreCase = true)
                }
            }
        } catch (e: Exception) {
            false
        }
    }

    // Check 4: Frida server binary on disk
    private fun isFridaFilePresent(): Boolean {
        return FRIDA_FILES.any { path -> File(path).exists() }
    }
}