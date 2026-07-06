import Foundation
import UIKit
import MachO 

internal struct JailbreakDetector {
    
    private static let jailbreakFiles = [
        "/Applications/Cydia.app",
        "/Applications/FakeCarrier.app",
        "/Applications/Icy.app",
        "/Applications/IntelliScreen.app",
        "/Applications/SBSettings.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
        "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        "/private/var/lib/apt",
        "/private/var/lib/cydia",
        "/private/var/mobile/Library/SBSettings/Themes",
        "/private/var/stash",
        "/private/var/tmp/cydia.log",
        "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
        "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        "/usr/bin/sshd",
        "/usr/libexec/sftp-server",
        "/usr/sbin/sshd",
        "/etc/apt",
        "/bin/bash",
        "/bin/sh",
    ]
    
    private static let suspiciousDylibs = [
        "MobileSubstrate",
        "substrate",
        "cynject",
        "substitute",
        "libhooker",
        "SubstrateInserter",
        "SubstrateLoader",
    ]
    
    static func isJailbroken() -> (jailbroken: Bool, threats: [String]) {
         #if targetEnvironment(simulator)
            return (jailbroken: false, threats: [])
         #else
        var threats: [String] = []
        
        if isJailbreakFilePresent() { threats.append("cydia_found") }
        if isSuspiciousDylibLoaded() { threats.append("suspicious_dylib") }
        if canWriteOutsideSandbox() { threats.append("sandbox_breach") }
        if canFork() { threats.append("fork_allowed") }
        if isSymlinkPresent() { threats.append("suspicious_symlink") }
        if isDynamicLibraryInjected() { threats.append("dylib_injected") }
        
        return (jailbroken: !threats.isEmpty, threats: threats)
        #endif
    }
    
    // Check 1: Known jailbreak files and apps
    private static func isJailbreakFilePresent() -> Bool {
        return jailbreakFiles.contains {
            FileManager.default.fileExists(atPath: $0)
        }
    }
    
    // Check 2: Suspicious dylibs loaded in memory
    private static func isSuspiciousDylibLoaded() -> Bool {
        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            if let imageName = _dyld_get_image_name(i) {
                let name = String(cString: imageName)
                if suspiciousDylibs.contains(where: {
                    name.contains($0)
                }) {
                    return true
                }
            }
        }
        return false
    }
    
    // Check 3: Write outside app sandbox
    // Sandboxed apps cannot write to arbitrary paths
    private static func canWriteOutsideSandbox() -> Bool {
        let path = "/private/shield_test_\(UUID().uuidString)"
        do {
            try "shield".write(
                toFile: path,
                atomically: true,
                encoding: .utf8
            )
            // Clean up if somehow succeeded
            try? FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
   // Check 4: posix_spawn capability
// Sandboxed apps cannot spawn processes —
// success here means sandbox restrictions are lifted
private static func canFork() -> Bool {
    var pid: pid_t = 0
    let argv: [UnsafeMutablePointer<CChar>?] = [nil]
    let envp: [UnsafeMutablePointer<CChar>?] = [nil]
    
    var fileActions: posix_spawn_file_actions_t?
    posix_spawn_file_actions_init(&fileActions)
    defer { posix_spawn_file_actions_destroy(&fileActions) }
    
    let result = posix_spawn(
        &pid,
        "/bin/bash",
        &fileActions,
        nil,
        argv + [nil],
        envp + [nil]
    )
    
    if result == 0 {
        kill(pid, SIGTERM)
        return true
    }
    return false
} 
    
    
    // Check 5: Suspicious symlinks
    // Jailbreaks often create symlinks to bypass sandbox
    private static func isSymlinkPresent() -> Bool {
        let suspiciousPaths = [
            "/var/lib/undecimus",
            "/Applications",
            "/Library/Ringtones",
            "/Library/Wallpaper",
            "/usr/arm-apple-darwin9",
            "/usr/include",
            "/usr/libexec",
            "/usr/share",
        ]
        
        return suspiciousPaths.contains { path in
            var isSymlink = false
            var isDirectory: ObjCBool = false
            
            if FileManager.default.fileExists(
                atPath: path,
                isDirectory: &isDirectory
            ) {
                let attributes = try? FileManager.default
                    .attributesOfItem(atPath: path)
                let fileType = attributes?[.type] as? FileAttributeType
                isSymlink = fileType == .typeSymbolicLink
            }
            return isSymlink
        }
    }
    
    // Check 6: DYLD_INSERT_LIBRARIES injection
    // Only possible on jailbroken devices
    private static func isDynamicLibraryInjected() -> Bool {
        return getenv("DYLD_INSERT_LIBRARIES") != nil
    }
}