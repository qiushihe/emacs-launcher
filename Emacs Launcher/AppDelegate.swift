//
//  AppDelegate.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
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
        
        statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType]);
        statusItem.button?.window?.delegate = self;
        
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
    
    // NSDraggingDestination Ptotocol
    // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Protocols/NSDraggingDestination_Protocol
    
    func draggingEntered (sender: NSDraggingInfo) -> NSDragOperation {
        NSLog("drag entered");
        return NSDragOperation.Link;
    }
    
    func draggingExited (sender: NSDraggingInfo) {
        NSLog("drag exited");
    }
    
    func prepareForDragOperation (sender: NSDraggingInfo) -> Bool {
        NSLog("drag prepare");
        return true; // Return true to accept
    }
    
    func performDragOperation (sender: NSDraggingInfo) -> Bool {
        NSLog("drag perform");
        let pboard = sender.draggingPasteboard();
        let files = pboard.propertyListForType(NSFilenamesPboardType) as Array<String>;
        return true;
    }
}
