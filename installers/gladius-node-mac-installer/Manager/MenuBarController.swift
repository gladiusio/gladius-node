//
//  MenuBarController.swift
//  Manager
//
//  Created by Nathan Feldsien on 5/31/18.
//  Copyright © 2018 Nathan Feldsien. All rights reserved.
//

import Cocoa

class MenuBarController: NSObject {
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var showManagerItem: NSMenuItem!
    @IBOutlet weak var quitItem: NSMenuItem!
    @IBOutlet weak var addToPathItem: NSMenuItem!
    
    var electronUI: Process?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var localPath: Bool {
        get {
            return isInPath()
        }
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: NSImage.Name(rawValue: "MenuBar"))
        icon?.size = NSSize(width: 16, height: 14)
        statusItem.image = icon
        statusItem.menu = mainMenu
        
        checkPath()
    }
    
    func checkPath() {
        if localPath {
            addToPathItem.isHidden = true
        }
    }
    
    func launchTerminalApp() {
        NSWorkspace.shared.launchApplication("Terminal", showIcon: false, autolaunch: false)
    }
    
    func launchElectronApp() {
        electronUI = Process()
        electronUI?.launchPath = Bundle.main.resourcePath! + "/Gladius.app/Contents/MacOS/Gladius"
        electronUI?.launch()
    }
    
    @IBAction func showManagerItemClicked(_ sender: NSMenuItem) {
        if (electronUI == nil) {
            launchElectronApp()
        } else {
            electronUI?.terminate()
            launchElectronApp()
        }
    }
    
    // Beta Options
    @IBAction func addToPathClicked(_ sender: Any) {
        if !localPath {
            addToPath()
            checkPath()
        }
    }
    
    @IBAction func openTerminalClicked(_ sender: Any) {
        launchTerminalApp()
    }
    
    @IBAction func quitItemClicked(_ sender: NSMenuItem) {
        electronUI?.terminate()
        NSApplication.shared.terminate(self)
    }
}
