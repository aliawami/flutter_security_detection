package com.aliAlawami.flutter_security_detection

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterShieldPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.flutter_shield/security")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkDevice" -> {
    val enableFrida = call.argument<Boolean>("enableFrida") ?: true
    val enableRoot = call.argument<Boolean>("enableRoot") ?: true
    val enableEmulator = call.argument<Boolean>("enableEmulator") ?: true
    val enableHookDetection = call.argument<Boolean>("enableHookDetection") ?: true
    val enableDebugDetection = call.argument<Boolean>("enableDebugDetection") ?: false

    Thread {
        try {
            val checkResult = DeviceIntegrityChecker.check(
                context = context,
                enableFrida = enableFrida,
                enableRoot = enableRoot,
                enableEmulator = enableEmulator,
                enableHookDetection = enableHookDetection,
                enableDebugDetection = enableDebugDetection,
            )
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                result.success(checkResult)
            }
        } catch (e: Exception) {
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                result.error("SHIELD_ERROR", e.message, null)
            }
        }
    }.start()
}
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}