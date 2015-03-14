//
//  CommandController.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-13.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

public class CommandController : NSObject {
    public func runCommand (cmd: String, args: Array<String>) -> String {
        NSLog("Running: " + cmd + " " + " ".join(args));
        
        let pipe = NSPipe();
        let task = taskForCommand(cmd, args: args);

        task.standardOutput = pipe;
        task.launch();
        task.waitUntilExit();
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile();
        let output = NSString(data: data, encoding: NSUTF8StringEncoding);
        
        if (output != nil) {
            return output!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
        } else {
            return "";
        }
    }
    
    public func runCommandWithoutOutput (cmd: String, args: Array<String>) -> NSTask {
        NSLog("Running: " + cmd + " " + " ".join(args));
        
        let task = taskForCommand(cmd, args: args);

        task.launch();
        task.waitUntilExit();
        
        return task;
    }
    
    func taskForCommand (cmd: String, args: Array<String>) -> NSTask {
        let task = NSTask();
        task.launchPath = cmd;
        task.arguments = args;
        return task;
    }
}