//
//  PreferenceController.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-13.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

class PreferenceController : NSObject, NSWindowDelegate {
    @IBOutlet weak var command: CommandRunner!;
    @IBOutlet weak var window: NSWindow!;
    
    var preferences: Dictionary<String, String>!;
    
    override init() {
        super.init();
        
        let data = NSUserDefaults.standardUserDefaults().objectForKey("preferences") as! NSData?;
        if (data != nil) {
            preferences = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>;
        } else {
            preferences = Dictionary<String, String>();
        }
        
        ensurePreferenceDefault("startServerAfterLaunch", defaultValue: "t");
        ensurePreferenceDefault("stopServerBeforeExit", defaultValue: "t");
        ensurePreferenceDefault("createNewFrameAfterLaunch", defaultValue: "t");
        ensurePreferenceDefault("maximizeNewFrameAfterLaunch", defaultValue: "t");
        ensurePreferenceDefault("alwaysCreateNewFrameForDroppedFiles", defaultValue: "f");
        ensurePreferenceDefault("maximizeNewFilesFrames", defaultValue: "f");
        ensurePreferenceDefault("maximizeNewFolderFrames", defaultValue: "f");
        
        ensurePreferenceDefault("defaultDirectory", defaultValue: NSHomeDirectory());
        ensurePreferenceDefault("serverPath", defaultValue: "/Applications/Emacs.app/Contents/MacOS/Emacs");
        ensurePreferenceDefault("clientPath", defaultValue: "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient");
        
        savePreferences();
    }
    
    var startServerAfterLaunch: Bool {
        get { return readBool("startServerAfterLaunch"); }
        set (value) { setBool("startServerAfterLaunch", value: value); }
    }
    
    var stopServerBeforeExit: Bool {
        get { return readBool("stopServerBeforeExit"); }
        set (value) { setBool("stopServerBeforeExit", value: value); }
    }
    
    var createNewFrameAfterLaunch: Bool {
        get { return readBool("createNewFrameAfterLaunch"); }
        set (value) { setBool("createNewFrameAfterLaunch", value: value); }
    }
    
    var maximizeNewFrameAfterLaunch: Bool {
        get { return readBool("maximizeNewFrameAfterLaunch"); }
        set (value) { setBool("maximizeNewFrameAfterLaunch", value: value); }
    }
    
    var alwaysCreateNewFrameForDroppedFiles: Bool {
        get { return readBool("alwaysCreateNewFrameForDroppedFiles"); }
        set (value) { setBool("alwaysCreateNewFrameForDroppedFiles", value: value); }
    }
    
    var maximizeNewFilesFrames: Bool {
        get { return readBool("maximizeNewFilesFrames"); }
        set (value) { setBool("maximizeNewFilesFrames", value: value); }
    }
    
    var maximizeNewFolderFrames: Bool {
        get { return readBool("maximizeNewFolderFrames"); }
        set (value) { setBool("maximizeNewFolderFrames", value: value); }
    }
    
    var defaultDirectory: String {
        get { return read("defaultDirectory"); }
        set (value) { set("defaultDirectory", value: value); }
    }
    
    var serverPath: String {
        get { return read("serverPath"); }
        set (value) { set("serverPath", value: value); }
    }
    var clientPath: String {
        get { return read("clientPath"); }
        set (value) { set("clientPath", value: value); }
    }
    
    func readBool (key: String) -> Bool {
        let value = preferences[key];
        return value != nil && value! == "t";
    }
    
    func setBool (key: String, value: Bool) {
        preferences[key] = value ? "t" : "f";
        savePreferences();
    }
    
    func read (key: String) -> String {
        return preferences[key]!;
    }
    
    func set (key: String, value: String) {
        preferences[key] = value;
        savePreferences();
    }
    
    func savePreferences () {
        // Note: I think there is a bug with NSKeyedArchiver.archivedDataWithRootObject, in that
        // it unnecessrily release the object passed into it thus making the reference invalid.
        // So for now, we make a temporary dictionary and archive that temporary dictionary instead
        // of the instance variable one.
        var _preferences = Dictionary<String, String>();
        for key in preferences.keys {
            let value: String = preferences[key]!;
            _preferences[key] = value;
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(_preferences);
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "preferences");
    }
    
    func ensurePreferenceDefault (key: String, defaultValue: String) {
        let value = preferences[key] as String?;
        if (value == nil || value!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 0) {
            preferences[key] = defaultValue;
        }
    }
    
    func showWindow () {
        window.makeKeyAndOrderFront(self);
        NSApp.activateIgnoringOtherApps(true);
    }
}