import Foundation

internal struct DeviceIntegrityChecker {
    
    static func check(
        enableFrida: Bool,
        enableJailbreak: Bool,
        enableDebug: Bool
    ) -> [String: Any] {
        var allThreats: [String] = []
        var isFridaDetected = false
        var isJailbroken = false
        
        if enableFrida {
            let (detected, threats) = FridaDetector.isFridaDetected()
            isFridaDetected = detected
            allThreats.append(contentsOf: threats)
        }
        
        if enableJailbreak {
            let (jailbroken, threats) = JailbreakDetector.isJailbroken()
            isJailbroken = jailbroken
            allThreats.append(contentsOf: threats)
        }
        
        if enableDebug {
            let (_, threats) = DebugDetector.isDebuggerAttached()
            allThreats.append(contentsOf: threats)
        }
        
        return [
            "passed": allThreats.isEmpty,
            "isJailbroken": isJailbroken,
            "isRooted": false,          // iOS has no root concept
            "isFridaDetected": isFridaDetected,
            "threats": allThreats,
        ]
    }
}