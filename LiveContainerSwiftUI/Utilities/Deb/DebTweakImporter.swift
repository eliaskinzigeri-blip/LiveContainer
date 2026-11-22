//
//  DebTweakImporter.swift
//  LiveContainerSwiftUI
//
//  SideStore shell: imports the tweak libraries of a jailbreak package (.deb) into a tweak folder.
//  The CydiaSubstrate dependency is pointed at the copy LiveContainer loads for every app, and
//  libraries that only exist on a jailbroken device are made optional.
//  needs proper testing on device
//

import Foundation

enum DebTweakImporter
{
    private static func isSubstrate(_ path: String) -> Bool {
        let lower = path.lowercased()
        return lower.contains("cydiasubstrate") || lower.contains("libsubstrate") || lower.contains("ellekit")
    }
    
    private static func isJailbreakPath(_ path: String) -> Bool {
        path.hasPrefix("/Library/") || path.hasPrefix("/var/jb/") || path.hasPrefix("/usr/local/")
    }
    
    /// Extracts the tweaks of `debURL` into `folderURL`. Returns the files written.
    static func importDeb(_ debURL: URL, into folderURL: URL) throws -> [URL] {
        let fileManager = FileManager.default
        var written: [URL] = []
        var needsShortSubstrate = false
        
        let package = try DebExtractor.extractPackage(from: debURL)
        for (name, data) in package.tweaks {
            let destination = folderURL.appendingPathComponent(name)
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try data.write(to: destination, options: .atomic)
            
            try MachOInjector.rewriteDependencies(of: destination) { path in
                if isSubstrate(path) {
                    let full = "@rpath/CydiaSubstrate.framework/CydiaSubstrate"
                    if path == full { return (nil, false) }
                    if path.utf8.count >= full.utf8.count { return (full, false) }
                    needsShortSubstrate = true
                    return ("@loader_path/libsubstrate.dylib", false)
                }
                if isJailbreakPath(path) {
                    return (nil, true)
                }
                return (nil, false)
            }
            written.append(destination)
        }
        
        // frameworks the tweak needs (e.g. SwiftProtobuf.framework), found through its @loader_path rpath
        written += try DebExtractor.writeFrameworkFiles(package.frameworkFiles, into: folderURL)
        
        if needsShortSubstrate {
            // rare: the tweak's CydiaSubstrate path is too short to point at LiveContainer's framework
            let substrate = Bundle.main.bundleURL.appendingPathComponent("Frameworks/CydiaSubstrate.framework/CydiaSubstrate")
            let alias = folderURL.appendingPathComponent("libsubstrate.dylib")
            if fileManager.fileExists(atPath: substrate.path), !fileManager.fileExists(atPath: alias.path) {
                try fileManager.copyItem(at: substrate, to: alias)
                written.append(alias)
            }
        }
        return written
    }
}
