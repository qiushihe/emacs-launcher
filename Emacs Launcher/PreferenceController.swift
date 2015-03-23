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
    
    func loadPreferences () -> Promise {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("preferences") as? NSData {
            preferences = NSKeyedUnarchiver.unarchiveObjectWithData(data) as Dictionary<String, String>;
        } else {
            preferences = Dictionary<String, String>();
        }
        
        return command.run("/bin/bash", args: ["-c", "echo $HOME"]).then({ (value: Value) -> Value in
            self.ensurePreferenceDefault("defaultDirectory", defaultValue: (value as String));
            self.ensurePreferenceDefault("serverPath", defaultValue: "/Applications/Emacs.app/Contents/MacOS/Emacs");
            self.ensurePreferenceDefault("clientPath", defaultValue: "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient");
            self.savePreferences();
            return nil;
        });
    }
    
    func savePreferences () {
        let data = NSKeyedArchiver.archivedDataWithRootObject(preferences);
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "preferences");
    }
    
    func ensurePreferenceDefault (key: String, defaultValue: String) {
        let value = preferences[key] as String?;
        if (value == nil || value!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 0) {
            preferences[key] = defaultValue;
        }
    }
}