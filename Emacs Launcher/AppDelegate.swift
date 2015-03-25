//
//  AppDelegate.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @IBOutlet weak var iconController: MenubarIconController!;
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var server: ServerController!;
    @IBOutlet weak var client: ClientController!;
    @IBOutlet weak var preferencesWindow: NSWindow!;
    @IBOutlet weak var menubarMenu: NSMenu!;
    
    var preferences: Dictionary<String, String>!;
    var statusItem: NSStatusItem!;
    var statusItemView: StatusItemView!;
    
    func applicationDidFinishLaunching (aNotification: NSNotification) {
        // TODO: Replace -2 with NSSquareStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2);
        statusItemView = StatusItemView(statusItem: statusItem);
        statusItemView.client = client;
        statusItemView.set(menu: menubarMenu);
        
        iconController.normal();
        
        preferenceController.loadPreferences().then({ (value: Value) -> Value in
            // TODO: Make starting server on startup optional
            return self.server.start();
        }).then({ (value: Value) -> Value in
            // TODO: Make launching client on startup optional
            return self.client.launchClient();
        });
    }
    
    func application(sender: NSApplication, openFiles filenames: [AnyObject]) {
        client.openFiles(filenames as Array<String>);
    }
    
    @IBAction func exit (sender: NSObject) {
        exit();
    }

    func exit () {
        // TODO: Make stopping server on exit optional
        server.stop().then({ (value: Value) -> Value in
            NSApplication.sharedApplication().terminate(self);
            return nil;
        });
    }
    
    @IBAction func showPreferences (sender: NSObject) {
        showPreferences();
    }
    
    func showPreferences () {
        preferencesWindow.makeKeyAndOrderFront(self);
        NSApp.activateIgnoringOtherApps(true);
    }
}
