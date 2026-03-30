import Foundation

internal struct DebugDetector {
    
    static func isDebuggerAttached() -> (detected: Bool, threats: [String]) {
        var threats: [String] = []
        
        if isBeingDebugged() { threats.append("debugger_attached") }
        if isDebugEnvironmentSet() { threats.append("debug_env_found") }
        
        return (detected: !threats.isEmpty, threats: threats)
    }
    
    // Check 1: sysctl — asks the kernel if a debugger is attached
    // This is the most reliable iOS debug detection
    private static func isBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.size
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        
        let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        guard result == 0 else { return false }
        
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    // Check 2: Debug-specific environment variables
    private static func isDebugEnvironmentSet() -> Bool {
        let debugEnvVars = [
            "DYLD_INSERT_LIBRARIES",
            "DYLD_LIBRARY_PATH",
            "DYLD_FRAMEWORK_PATH",
        ]
        let env = ProcessInfo.processInfo.environment
        return debugEnvVars.contains { env[$0] != nil }
    }
}