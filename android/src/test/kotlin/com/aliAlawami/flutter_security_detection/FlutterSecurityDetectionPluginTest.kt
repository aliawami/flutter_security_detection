package com.aliAlawami.flutter_security_detection

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * Unit tests for the Kotlin side of the plugin. Run them with
 * `./gradlew testDebugUnitTest` in the `example/android/` directory, or from
 * an IDE that supports JUnit such as Android Studio.
 */

internal class FlutterSecurityDetectionPluginTest {
    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = FlutterSecurityDetectionPlugin()

        val call = MethodCall("doesNotExist", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }
}
