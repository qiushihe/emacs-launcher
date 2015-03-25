//
//  CommandRunner.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-13.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

class CommandRunner : NSObject {
    @IBOutlet weak var iconController: MenubarIconController!;
    
    var busy = false;
    
    func run (cmd: String, args: Array<String>) -> Promise {
        NSLog("Running: " + cmd + " " + " ".join(args));
        
        let pipe = NSPipe();
        let task = taskForCommand(cmd, args: args);
        
        task.standardOutput = pipe;
        task.standardError = pipe;
        
        iconController.loading();
        busy = true;
        
        return Craft.promise({
            (resolve: (value: Value) -> (), reject: (value: Value) -> ()) -> () in
            
            task.terminationHandler = { (task: NSTask!) in
                let data = pipe.fileHandleForReading.readDataToEndOfFile();
                var output = NSString(data: data, encoding: NSUTF8StringEncoding);
                
                if (output == nil) {
                    output = "";
                } else {
                    output = output!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
                }
                
                self.busy = false;
                self.iconController.normal();

                resolve(value: output!);
            }
            
            task.launch();
        });
    }
    
    func taskForCommand (cmd: String, args: Array<String>) -> NSTask {
        let task = NSTask();
        task.launchPath = cmd;
        task.arguments = args;
        return task;
    }
}