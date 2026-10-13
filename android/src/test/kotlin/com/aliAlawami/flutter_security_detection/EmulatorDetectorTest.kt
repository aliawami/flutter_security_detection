package com.aliAlawami.flutter_security_detection

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class EmulatorDetectorTest {
    private fun match(
        fingerprint: String? = "google/husky/husky:15/AP4A/1:user/release-keys",
        model: String? = "Pixel 8 Pro",
        manufacturer: String? = "Google",
        brand: String? = "google",
        device: String? = "husky",
        product: String? = "husky",
        hardware: String? = "husky",
    ) = EmulatorDetector.matchesEmulatorBuild(
        fingerprint, model, manufacturer, brand, device, product, hardware
    )

    @Test
    fun realDevice_isNotFlagged() = assertFalse(match())

    @Test
    fun customRomWithTestKeys_isNotFlagged() {
        assertFalse(match(fingerprint = "lineage/fajita/fajita:14/UP1A/1:userdebug/test-keys"))
    }

    @Test
    fun unknownFingerprintPrefix_isNotFlagged() {
        assertFalse(match(fingerprint = "unknown/product/device:14/ABC/1:user/release-keys"))
    }

    @Test
    fun androidStudioEmulator_isFlagged() {
        assertTrue(
            match(
                fingerprint = "google/sdk_gphone64_x86_64/emu64xa:15/AE3A/1:userdebug/dev-keys",
                model = "sdk_gphone64_x86_64",
                product = "sdk_gphone64_x86_64",
                hardware = "ranchu",
            )
        )
    }

    @Test
    fun genymotion_isFlagged() = assertTrue(match(manufacturer = "Genymotion"))

    @Test
    fun virtualBoxHardware_isFlagged() = assertTrue(match(hardware = "vbox86"))

    @Test
    fun nullBuildFields_doNotCrash() {
        assertFalse(match(null, null, null, null, null, null, null))
    }
}
