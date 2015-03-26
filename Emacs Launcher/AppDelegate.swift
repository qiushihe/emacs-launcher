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
        statusItemView.app = self;
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
        openFiles(filenames as Array<String>);
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
    
    func openFiles (files: Array<String>) {
        // We can't use on prepareForDragOperation to filter acceptable dragged objects because
        // when dragging from a Stack in the dock into the NSStatusItem's view, the
        // prepareForDragOperation is never called. So We just have to do the filter right here
        // right before we pass the paths to Emacs client. Acceptable drops are either a single
        // directory, or any number of files.
        
        var filesCount = 0;
        var directoriesCount = 0;
        
        for path in files {
            if (isPathDirectory(path)) {
                directoriesCount++;
            } else {
                filesCount++;
            }
        }
        
        if (directoriesCount <= 0 && filesCount > 0) {
            client.openFiles(files);
        } else if (directoriesCount == 1 && filesCount <= 0) {
            client.openFolder(files.first!);
        } else {
            // TODO: Show error popup with message for invalid drops
        }
    }
    
    func isPathDirectory (path: String) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(false);
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) {
            println(isDirectory)
        }
        return Bool(isDirectory);
    }
}
