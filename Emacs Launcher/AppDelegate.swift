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
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var server: ServerController!;
    @IBOutlet weak var client: ClientController!;
    @IBOutlet weak var iconController: MenubarIconController!;
    @IBOutlet weak var preferencesWindow: NSWindow!;
    @IBOutlet weak var menubarMenu: NSMenu!;
    
    var preferences: Dictionary<String, String>!;
    var statusItem: NSStatusItem!;
    
    public func applicationDidFinishLaunching (aNotification: NSNotification) {
        preferenceController.loadPreferences();
        
        // TODO: Replace -1 with NSVariableStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusItem.menu = menubarMenu;
        
        statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType]);
        statusItem.button?.window?.delegate = self;
        
        iconController.normal();
        
        // TODO: Make starting server on startup optional
        // server.start();
        // client.launchClient();
    }

    public func applicationWillTerminate (aNotification: NSNotification) {
        // TODO: Make stopping server on exit optional
        server.stop();
    }
    
    @IBAction public func exit (sender: NSObject? = nil) {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: NSApp, selector: Selector("terminate:"), userInfo: nil, repeats: false);
    }
    
    @IBAction public func showPreferences (sender: NSObject? = nil) {
        preferencesWindow.makeKeyAndOrderFront(self);
        NSApp.activateIgnoringOtherApps(true);
    }
    
    func draggingEntered (sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Link;
    }
    
    func prepareForDragOperation (sender: NSDraggingInfo) -> Bool {
        return true;
    }
    
    func draggingEnded(sender: NSDraggingInfo?) {
        let location = sender?.draggingLocation();
        let frame = statusItem.button?.frame;
        
        // Work around a DnD bug: http://stackoverflow.com/a/10825816
        if (location != nil && frame != nil && NSPointInRect(location!, frame!)) {
            performDragOperation(sender!);
        }
    }
    
    func performDragOperation (sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard();
        let files = pboard.propertyListForType(NSFilenamesPboardType) as Array<String>;
        
        // Reverse the opening order so the first file is the last to be opened and thus
        // is the one the user is looking at in the end
        for filePath in files.reverse() {
            client.openFile(filePath);
        }

        return true;
    }
}
