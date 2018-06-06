//
//  AppDelegate.swift
//  Test
//
//  Created by Nathan Feldsien on 5/18/18.
//  Copyright © 2018 Nathan Feldsien. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var controldProcess: Process?
    var networkdProcess: Process?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        config()
        
        let _ = shell(command: Bundle.main.resourcePath! + "/gladius-controld", output: false, process: controldProcess)
        let _ = shell(command: Bundle.main.resourcePath! + "/gladius-networkd", output: false, process: networkdProcess)
        
        launchAgent()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        quitAll()
    }
    
    func quitAll() {
        controldProcess?.terminate()
        networkdProcess?.terminate()
    }
}

