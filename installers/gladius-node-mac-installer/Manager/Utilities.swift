//
//  Utilities.swift
//  Gladius
//
//  Created by Nathan Feldsien on 6/6/18.
//  Copyright © 2018 Nathan Feldsien. All rights reserved.
//

import Foundation
import ServiceManagement

let homeFolderURL = FileManager.default.homeDirectoryForCurrentUser

public func shell(command: String, output: Bool, process sentProcess: Process?) -> String? {
    let process: Process
    if let sentProcess = sentProcess {
        process = sentProcess
    } else {
        process = Process()
    }
    
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", command]
    
    if output {
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        
        return output
    } else {
        process.launch()
        return nil
    }
}

public func config() {
    try? FileManager.default.createDirectory(at: homeFolderURL.appendingPathComponent(".config/gladius/wallet"), withIntermediateDirectories: true, attributes: nil)
    try? FileManager.default.createDirectory(at: homeFolderURL.appendingPathComponent(".config/gladius/keys"), withIntermediateDirectories: true, attributes: nil)
    try? FileManager.default.createDirectory(at: homeFolderURL.appendingPathComponent(".config/gladius/content"), withIntermediateDirectories: true, attributes: nil)
}

func update() {
    try? FileManager.default.removeItem(at: URL(string: "file:///usr/local/bin/gladius")!)
}

public func launchAgent() {
    try? FileManager.default.createDirectory(at: homeFolderURL.appendingPathComponent("Library/LaunchAgents"), withIntermediateDirectories: false, attributes: nil)
    
    do {
        try FileManager.default.createSymbolicLink(at: homeFolderURL.appendingPathComponent("Library/LaunchAgents/com.gladius.io.node-manager.plist"), withDestinationURL: URL(fileURLWithPath: Bundle.main.resourcePath! + "/com.gladius.io.node-manager.plist"))
    } catch {
        print(error)
    }
}

public func isInPath() -> Bool {
    let symlinkExists = FileManager.default.fileExists(atPath: "/usr/local/bin/gladius")
    let zshrcExists = FileManager.default.fileExists(atPath: homeFolderURL.appendingPathComponent(".zshrc").absoluteString.replacingOccurrences(of: "file://", with: ""))
    
    let rcFile: String
    if zshrcExists {
        rcFile = ".zshrc"
    } else {
        rcFile = ".bash_profile"
    }
    
    let profileExport: Bool
    if let shellPreferences = shell(command: "cat ~/\(rcFile)", output: true, process: nil) {
        profileExport = shellPreferences.contains("gladius/paths")
    } else {
        profileExport = false
    }
    
    return (symlinkExists || profileExport)
}

public func addToPath() {
    do {
        let symlinkExists = FileManager.default.fileExists(atPath: "/usr/local/bin/gladius")
        if !symlinkExists {
            try FileManager.default.createSymbolicLink(at: URL(string: "file:///usr/local/bin/gladius")!, withDestinationURL: URL(fileURLWithPath: Bundle.main.resourcePath! + "/gladius"))
        }
    } catch {
        let zshrcExists = FileManager.default.fileExists(atPath: homeFolderURL.appendingPathComponent(".zshrc").absoluteString.replacingOccurrences(of: "file://", with: ""))
        
        let rcFile: String
        if zshrcExists {
            rcFile = ".zshrc"
        } else {
            rcFile = ".bash_profile"
        }
        
        guard let shellPreferences = shell(command: "cat ~/\(rcFile)", output: true, process: nil)
            else {
                return
        }
        
        if !shellPreferences.contains("gladius/paths") {
            let _ = shell(command: "echo \"export PATH=\\$PATH:/Applications/Gladius.app/Contents/Resources\"  > ~/.config/gladius/paths", output: false, process: nil)
            let _ = shell(command: "echo \"source ~/.config/gladius/paths\"  >> ~/\(rcFile)", output: false, process: nil)
        }
    }
}
