//
//  AppDelegate.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate, LauncherMenuAppDelegate {
    @IBOutlet weak var window: NSWindow!;
    
    var statusItem: NSStatusItem!;
    var statusMenu: LauncherMenu!;
    var server: ServerController!;
    
    public func applicationDidFinishLaunching (aNotification: NSNotification) {
        statusMenu = LauncherMenu();
        server = ServerController();
        
        server.stateDelegate = statusMenu;
        statusMenu.appDelegate = self;
        statusMenu.serverDelegate = server;
        
        // TODO: Replace -1 with NSVariableStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusItem.image = NSImage(named: "switchIcon");
        statusItem.menu = statusMenu.updateMenu();
    }

    public func applicationWillTerminate (aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    public func exit () {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: NSApp, selector: Selector("terminate:"), userInfo: nil, repeats: false);
    }
}
