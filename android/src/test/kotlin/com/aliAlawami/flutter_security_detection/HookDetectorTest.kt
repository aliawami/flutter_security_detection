package com.aliAlawami.flutter_security_detection

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class HookDetectorTest {
    private fun frame(cls: String) = StackTraceElement(cls, "main", "File.java", 1)

    @Test
    fun stackWithXposedBridge_isDetected() {
        val stack = arrayOf(
            frame("com.android.internal.os.ZygoteInit"),
            frame("de.robv.android.xposed.XposedBridge"),
        )
        assertTrue(HookDetector.hasXposedFrame(stack))
    }

    @Test
    fun ordinaryStack_isNotDetected() {
        val stack = arrayOf(
            frame("java.lang.Thread"),
            frame("com.aliAlawami.flutter_security_detection.HookDetector"),
        )
        assertFalse(HookDetector.hasXposedFrame(stack))
    }

    @Test
    fun emptyStack_isNotDetected() = assertFalse(HookDetector.hasXposedFrame(emptyArray()))
}
