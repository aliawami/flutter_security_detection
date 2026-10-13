package com.aliAlawami.flutter_security_detection

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class RootDetectorTest {
    @Test
    fun suOnPath_findsSuInAnyPathEntry() {
        val present = setOf("/odm/bin/su")
        assertTrue(RootDetector.suOnPath("/system/bin:/odm/bin/:/vendor/bin") { it in present })
    }

    @Test
    fun suOnPath_returnsFalseWhenAbsent() {
        assertFalse(RootDetector.suOnPath("/system/bin:/vendor/bin") { false })
    }

    @Test
    fun suOnPath_handlesNullEmptyAndBlankEntries() {
        assertFalse(RootDetector.suOnPath(null) { true })
        assertFalse(RootDetector.suOnPath("") { true })
        assertFalse(RootDetector.suOnPath("::") { true })
    }
}
