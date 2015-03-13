//
//  LauncherMenu.swift
//  Emacs Launcher
//
//  Created by Billy He on 2015-03-12.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

protocol LauncherMenuAppDelegate : NSObjectProtocol {
    func exit();
}

protocol LauncherMenuServerDelegate : NSObjectProtocol {
    func isRunning() -> Bool;
    func getPid() -> Int;
    func start();
    func stop();
    func restart();
}

public class LauncherMenu: NSMenu, ServerControllerStateDelegate {
    var appDelegate: LauncherMenuAppDelegate!;
    var serverDelegate: LauncherMenuServerDelegate!;
    var menuItemKeys: Dictionary<NSMenuItem, String>!;
    
    public required init (coder: NSCoder) {
        super.init(coder: coder);
    }
    
    public override init () {
        super.init(title: "Emacs Launcher Menu");
        menuItemKeys = Dictionary<NSMenuItem, String>();
    }
    
    public func updateMenu () -> LauncherMenu {
        removeAllItems();
        
        var serverStatus = "Server: " + (serverDelegate.isRunning() ? ("Running (PID " + String(serverDelegate.getPid()) + ")") : "Not running");
        addItem(NSMenuItem(title: serverStatus, action: nil, keyEquivalent: ""));
        
        if (!serverDelegate.isRunning()) {
            addMenuItem("start", title: "Start server");
        } else {
            addMenuItem("stop", title: "Stop server");
            addMenuItem("restart", title: "Restart server");
        }
        
        addMenuItem("exit", title: "Exit Emacs Launcher");
        
        for menuItem: NSMenuItem in itemArray as [NSMenuItem] {
            menuItem.target = self;
        }
        
        return self;
    }
    
    func addMenuItem (key: String, title: String) {
        var item = NSMenuItem(title: title, action: Selector("menuItemAction:"), keyEquivalent: "");
        menuItemKeys[item] = key;
        addItem(item);
    }
    
    func menuItemAction (sender: NSMenuItem) {
        var key = menuItemKeys[sender];
        NSLog("Server command: " + key!);
        
        if (key == "exit") {
            serverDelegate.stop();
            appDelegate.exit();
        } else if (key == "start") {
            serverDelegate.start();
        } else if (key == "stop") {
            serverDelegate.stop();
        } else if (key == "restart") {
            serverDelegate.restart();
        }
    }
    
    func stateDidChange() {
        updateMenu();
    }
}