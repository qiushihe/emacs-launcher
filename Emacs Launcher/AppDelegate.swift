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
    @IBOutlet weak var menubarMenu: NSMenu!;
    
    var statusItem: NSStatusItem!;
    var statusItemView: StatusItemView!;
    
    var appLaunched = Deferred.create();
    
    func applicationDidFinishLaunching (aNotification: NSNotification) {
        // TODO: Replace -2 with NSSquareStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2);
        statusItemView = StatusItemView(statusItem: statusItem);
        statusItemView.app = self;
        statusItemView.set(menu: menubarMenu);
        
        iconController.normal();
        
        if (preferenceController.readBool("startServerAfterLaunch")) {
            server.start().then({ (value: Value) -> Value in
                if (self.preferenceController.readBool("createNewFrameAfterLaunch")) {
                    return self.client.launchClient();
                } else {
                    return nil;
                }
            });
        }
        
        appLaunched.resolve(nil);
    }
    
    func application(sender: NSApplication, openFiles filenames: [AnyObject]) {
        appLaunched.promise.then({ (value: Value) -> Value in
            self.openFiles(filenames as! Array<String>);
            return nil;
        });
    }
    
    @IBAction func exit (sender: NSObject) {
        exit();
    }

    func exit () {
        if (preferenceController.readBool("stopServerBeforeExit")) {
            server.stop().then({ (value: Value) -> Value in
                NSApplication.sharedApplication().terminate(self);
                return nil;
            });
        } else {
            NSApplication.sharedApplication().terminate(self);
        }
    }
    
    @IBAction func showPreferences (sender: NSObject) {
        preferenceController.showWindow();
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
        
        server.start().then({ (value: Value) -> Value in
            if (directoriesCount <= 0 && filesCount > 0) {
                self.client.openFiles(files);
            } else if (directoriesCount == 1 && filesCount <= 0) {
                self.client.openFolder(files.first!);
            } else {
                // TODO: Show error popup with message for invalid drops
            }
            return nil;
        });
    }
    
    func isPathDirectory (path: String) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(false);
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) {
            println(isDirectory)
        }
        return Bool(isDirectory);
    }
}
