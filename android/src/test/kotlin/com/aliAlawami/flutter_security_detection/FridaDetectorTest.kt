package com.aliAlawami.flutter_security_detection

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class FridaDetectorTest {
    @Test
    fun maps_withFridaAgent_isDetected() {
        val lines = listOf(
            "7f1000-7f2000 r-xp 00000000 fd:00 1 /system/lib64/libc.so",
            "7f3000-7f4000 r-xp 00000000 fd:00 2 /data/local/tmp/re.frida.server/frida-agent-64.so",
        )
        assertTrue(FridaDetector.mapsContainFrida(lines))
    }

    @Test
    fun maps_withGadget_isDetected() {
        val lines = listOf("7f3000-7f4000 r-xp 0 fd:00 2 /data/app/x/lib/arm64/libfrida-gadget.so")
        assertTrue(FridaDetector.mapsContainFrida(lines))
    }

    @Test
    fun maps_withFridayInPath_isNotDetected() {
        // "Friday" contains the substring "frida" — must not be a false positive.
        val lines = listOf(
            "7f1000-7f2000 r--s 0 fd:00 3 /system/fonts/FridayScript-Regular.ttf",
            "7f1000-7f2000 r--s 0 fd:00 4 /data/app/com.example.fridayplanner/base.apk",
        )
        assertFalse(FridaDetector.mapsContainFrida(lines))
    }

    @Test
    fun cmdline_fridaServer_isDetected() {
        val raw = "/data/local/tmp/frida-server\u0000-l\u00000.0.0.0".toByteArray()
        assertTrue(FridaDetector.isFridaCmdline(raw))
    }

    @Test
    fun cmdline_ordinaryApp_isNotDetected() {
        assertFalse(FridaDetector.isFridaCmdline("com.example.myapp".toByteArray()))
    }

    @Test
    fun cmdline_appWithFridaInPackageName_isNotDetected() {
        assertFalse(FridaDetector.isFridaCmdline("com.example.fridaapp".toByteArray()))
    }
}
