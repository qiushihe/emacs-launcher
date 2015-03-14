//
//  AppDelegate.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var menu: LauncherMenu!;
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var server: ServerController!;
    @IBOutlet weak var client: ClientController!;
    
    var preferences: Dictionary<String, String>!;
    var statusItem: NSStatusItem!;
    
    public func applicationDidFinishLaunching (aNotification: NSNotification) {
        preferenceController.loadPreferences();
        
        // TODO: Replace -1 with NSVariableStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusItem.image = NSImage(named: "Menubar Icon");
        statusItem.menu = menu.updateMenu();
        
        // TODO: Make starting server on startup optional
        server.start();
        client.start();
    }

    public func applicationWillTerminate (aNotification: NSNotification) {
        // TODO: Make stopping server on exit optional
        server.stop();
    }
    
    public func exit () {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: NSApp, selector: Selector("terminate:"), userInfo: nil, repeats: false);
    }
}
