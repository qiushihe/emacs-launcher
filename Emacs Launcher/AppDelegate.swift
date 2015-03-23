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
    @IBOutlet weak var iconController: MenubarIconController!;
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var server: ServerController!;
    @IBOutlet weak var client: ClientController!;
    @IBOutlet weak var preferencesWindow: NSWindow!;
    @IBOutlet weak var menubarMenu: NSMenu!;
    
    var preferences: Dictionary<String, String>!;
    var statusItem: NSStatusItem!;
    
    public func applicationDidFinishLaunching (aNotification: NSNotification) {
        // TODO: Replace -1 with NSVariableStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusItem.menu = menubarMenu;
        
        statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType]);
        statusItem.button?.window?.delegate = self;
        
        iconController.normal();
        
        preferenceController.loadPreferences().then({ (value: Value) -> Value in
            // TODO: Make starting server on startup optional
            return self.server.start();
        }).then({ (value: Value) -> Value in
            // TODO: Make launching client on startup optional
            return self.client.launchClient();
        });
    }
    
    @IBAction public func exit (sender: NSObject) {
        exit();
    }

    public func exit () {
        // TODO: Make stopping server on exit optional
        server.stop().then({ (value: Value) -> Value in
            NSApplication.sharedApplication().terminate(self);
            return nil;
        });
    }
    
    @IBAction public func showPreferences (sender: NSObject) {
        showPreferences();
    }
    
    public func showPreferences () {
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
