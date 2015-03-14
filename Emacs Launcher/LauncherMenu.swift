//
//  LauncherMenu.swift
//  Emacs Launcher
//
//  Created by Billy He on 2015-03-12.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

public class LauncherMenu: NSMenu {
    var appDelegate: AppDelegate!;
    var server: ServerController!;
    var client: ClientController!;
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
        
        var serverStatus = "Server: " + (server.isRunning() ? ("Running (PID " + String(server.getPid()) + ")") : "Not running");
        addItem(NSMenuItem(title: serverStatus, action: nil, keyEquivalent: ""));
        
        if (!server.isRunning()) {
            addMenuItem("start-server", title: "Start server");
        } else {
            addMenuItem("stop-server", title: "Stop server");
            addMenuItem("restart-server", title: "Restart server");
            addMenuItem("restart-both", title: "Restart server/client");
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
            appDelegate.exit();
        } else if (key == "start-server") {
            server.start();
        } else if (key == "stop-server") {
            server.stop();
        } else if (key == "restart-server") {
            server.restart();
        } else if (key == "restart-both") {
            server.restart();
            client.start();
        }
    }
}