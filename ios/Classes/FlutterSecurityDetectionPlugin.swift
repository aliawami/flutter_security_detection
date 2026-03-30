import Flutter
import UIKit

public class FlutterSecurityDetectionPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.flutter_shield/security",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterSecurityDetectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "checkDevice":
            let args = call.arguments as? [String: Any] ?? [:]
            
            let enableFrida = args["enableFrida"] as? Bool ?? true
            let enableJailbreak = args["enableJailbreak"] as? Bool ?? true
            let enableDebugDetection = args["enableDebugDetection"] as? Bool ?? false
            
            // Run on background thread — never block main thread
            DispatchQueue.global(qos: .userInitiated).async {
                let checkResult = DeviceIntegrityChecker.check(
                    enableFrida: enableFrida,
                    enableJailbreak: enableJailbreak,
                    enableDebug: enableDebugDetection
                )
                
                // Return to main thread for Flutter result
                DispatchQueue.main.async {
                    result(checkResult)
                }
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}