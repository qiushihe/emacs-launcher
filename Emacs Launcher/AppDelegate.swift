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
    @IBOutlet weak var window: NSWindow!;
    
    var preferences: Dictionary<String, String>!;
    var statusItem: NSStatusItem!;
    var statusMenu: LauncherMenu!;
    var server: ServerController!;
    var client: ClientController!;
    var command: CommandController!;
    
    public func applicationDidFinishLaunching (aNotification: NSNotification) {
        loadPreferences();
        
        command = CommandController();
        
        client = ClientController(aPath: preferences["clientPath"]!);
        client.command = command;
        
        statusMenu = LauncherMenu();
        server = ServerController(aPath: preferences["serverPath"]!);
        server.command = command;
        server.client = client;
        
        server.menu = statusMenu;
        statusMenu.appDelegate = self;
        statusMenu.server = server;
        statusMenu.client = client;
        
        // TODO: Replace -1 with NSVariableStatusItemLength after Swift fixes its bug
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusItem.image = NSImage(named: "switchIcon");
        statusItem.menu = statusMenu.updateMenu();
        
        // TODO: Make starting server on startup optional
        server.start();
        client.start();
    }

    public func applicationWillTerminate (aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    public func exit () {
        // TODO: Make stopping server on exit optional
        server.stop();

        NSTimer.scheduledTimerWithTimeInterval(0.1, target: NSApp, selector: Selector("terminate:"), userInfo: nil, repeats: false);
    }
    
    func loadPreferences () {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("preferences") as? NSData {
            preferences = NSKeyedUnarchiver.unarchiveObjectWithData(data) as Dictionary<String, String>;
        } else {
            preferences = Dictionary<String, String>();
        }
        
        ensureAllPreferenceDefaults();
        savePreferences();
    }
    
    func savePreferences () {
        let data = NSKeyedArchiver.archivedDataWithRootObject(preferences);
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "preferences");
    }
    
    func ensureAllPreferenceDefaults () {
        ensurePreferenceDefault("serverPath", defaultValue: "/Applications/Emacs.app/Contents/MacOS/Emacs");
        ensurePreferenceDefault("clientPath", defaultValue: "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient");
    }
    
    func ensurePreferenceDefault (key: String, defaultValue: String) {
        let value = preferences[key] as String?;
        if (value == nil || value!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 0) {
            preferences[key] = defaultValue;
        }
    }
}
