//
//  AppDelegate.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!;
    
    var statusItem: NSStatusItem!;
    var statusMenu: LauncherMenu!;
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // TODO: Replace -1 with NSVariableStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusItem.image = NSImage(named: "switchIcon");
        
        statusMenu = LauncherMenu();
        statusMenu.addItem(NSMenuItem(title: "aHah", action: nil, keyEquivalent: ""));
        
        statusItem.menu = statusMenu;
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}
