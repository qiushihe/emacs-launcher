//
//  PreferenceController.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-13.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

public class PreferenceController : NSObject {
    @IBOutlet weak var command: CommandRunner!;
    
    var preferences: Dictionary<String, String>!;
    
    func read (key: String) -> String {
        return preferences[key]!;
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
        ensurePreferenceDefault("defaultDirectory", defaultValue: command.runCommand("/bin/bash", args: ["-c", "echo $HOME"]));
    }
    
    func ensurePreferenceDefault (key: String, defaultValue: String) {
        let value = preferences[key] as String?;
        if (value == nil || value!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 0) {
            preferences[key] = defaultValue;
        }
    }
}