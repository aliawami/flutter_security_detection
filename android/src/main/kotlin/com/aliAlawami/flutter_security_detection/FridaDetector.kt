package com.aliAlawami.flutter_security_detection

import java.io.File
import java.net.InetSocketAddress
import java.net.Socket

internal object FridaDetector {

    private const val FRIDA_PORT = 27042
    private const val CONNECT_TIMEOUT_MS = 500

    // Specific on purpose: a bare "frida" would also match unrelated names
    // such as "Friday" in a mapped font or asset path.
    private val FRIDA_LIBRARIES = listOf(
        "frida-agent",
        "frida-gadget",
        "re.frida.",
    )

    private val FRIDA_PROCESS_NAMES = listOf(
        "frida-server",
        "re.frida.server",
        "frida-helper",
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

    // Check 1: Frida server default port.
    // Note: opening a socket needs the INTERNET permission. Without it the
    // connect throws and this check silently reports "not found"; the other
    // checks are unaffected.
    private fun isFridaPortOpen(): Boolean {
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", FRIDA_PORT), CONNECT_TIMEOUT_MS)
                true
            }
        } catch (e: Exception) {
            false
        }
    }

    // Check 2: Frida server in running processes.
    // Process scanning is restricted by Android's process isolation on
    // Android 7+: only processes of the same UID are readable, so this is a
    // best-effort signal. Port and file detection are the primary signals.
    private fun isFridaProcessRunning(): Boolean {
        return try {
            File("/proc").listFiles()?.any { procDir ->
                if (procDir.isDirectory && procDir.name.all { it.isDigit() }) {
                    val cmdlineFile = File(procDir, "cmdline")
                    cmdlineFile.exists() && isFridaCmdline(cmdlineFile.readBytes())
                } else false
            } ?: false
        } catch (e: Exception) {
            false
        }
    }

    // /proc/<pid>/cmdline is NUL-separated.
    internal fun isFridaCmdline(raw: ByteArray): Boolean {
        val cmdline = String(raw, Charsets.ISO_8859_1).replace('\u0000', ' ')
        return FRIDA_PROCESS_NAMES.any { cmdline.contains(it, ignoreCase = true) }
    }

    // Check 3: Frida agent loaded in memory maps
    private fun isFridaLibraryLoaded(): Boolean {
        return try {
            val mapsFile = File("/proc/self/maps")
            if (!mapsFile.exists()) return false
            mapsContainFrida(mapsFile.readLines())
        } catch (e: Exception) {
            false
        }
    }

    internal fun mapsContainFrida(lines: List<String>): Boolean {
        return lines.any { line ->
            FRIDA_LIBRARIES.any { lib -> line.contains(lib, ignoreCase = true) }
        }
    }

    // Check 4: Frida server binary on disk
    private fun isFridaFilePresent(): Boolean {
        return FRIDA_FILES.any { path -> File(path).exists() }
    }
}