//
//  AppDelegate.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

// https://nsrover.wordpress.com/2014/10/10/creating-a-os-x-menubar-only-app

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!;
    
    var statusItem: NSStatusItem!;
    var darkModeOn: Bool!;
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength);
        self.statusItem.image = NSImage(named: "switchIcon.png");
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}
