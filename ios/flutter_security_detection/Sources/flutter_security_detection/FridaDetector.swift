import Foundation
import MachO 

internal struct FridaDetector {
    
    private static let fridaPort: Int32 = 27042
    
    private static let fridaLibraries = [
        "frida-agent",
        "frida-gadget",
        "FridaGadget",
    ]
    
    private static let fridaFiles = [
        "/usr/sbin/frida-server",
        "/tmp/frida-server",
        "/usr/bin/frida-server",
    ]
    
    static func isFridaDetected() -> (detected: Bool, threats: [String]) {
        #if targetEnvironment(simulator)
    return (detected: false, threats: [])
    #else
        var threats: [String] = []
        
        if isFridaPortOpen() { threats.append("frida_port_open") }
        if isFridaLibraryLoaded() { threats.append("frida_library_found") }
        if isFridaFilePresent() { threats.append("frida_file_found") }
        if isFridaEnvironmentPresent() { threats.append("frida_env_found") }
        
        return (detected: !threats.isEmpty, threats: threats)
        #endif
    }
    
    // Check 1: Frida server default port
    private static func isFridaPortOpen() -> Bool {
        let socketFD = socket(AF_INET, SOCK_STREAM, 0)
        guard socketFD >= 0 else { return false }
        defer { close(socketFD) }
        
        var address = sockaddr_in()
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = in_port_t(fridaPort).bigEndian
        address.sin_addr.s_addr = inet_addr("127.0.0.1")
        
        let result = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        
        return result == 0
    }
    
    // Check 2: Frida agent loaded in memory
    private static func isFridaLibraryLoaded() -> Bool {
        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            if let imageName = _dyld_get_image_name(i) {
                let name = String(cString: imageName).lowercased()
                if fridaLibraries.contains(where: { name.contains($0.lowercased()) }) {
                    return true
                }
            }
        }
        return false
    }
    
    // Check 3: Frida server binary on disk
    private static func isFridaFilePresent() -> Bool {
        return fridaFiles.contains { FileManager.default.fileExists(atPath: $0) }
    }
    
    // Check 4: Frida injects environment variables
    private static func isFridaEnvironmentPresent() -> Bool {
        let env = ProcessInfo.processInfo.environment
        return env.keys.contains(where: {
            $0.lowercased().contains("frida") ||
            $0.lowercased().contains("gadget")
        })
    }
}