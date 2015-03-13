//
//  ServerController.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

@objc protocol ServerControllerStateDelegate : NSObjectProtocol {
    optional func stateDidChange();
    optional func stateWillChange();
}

public class ServerController : NSObject, LauncherMenuServerDelegate {
    var running: Bool!;
    var pid: Int!;
    var stateDelegate: ServerControllerStateDelegate!;
    var serverPath: String!;
    var clientPath: String!;
    
    public init (server: String, client: String) {
        super.init();
        running = false;
        pid = 0;
        serverPath = server;
        clientPath = client;
    }
    
    public func isRunning () -> Bool {
        return running;
    }
    
    public func getPid () -> Int {
        return pid;
    }
    
    public func start () {
        stateDelegate?.stateWillChange?();
        
        pid = checkPid();
        if (pid > 0) {
            NSLog("Emacs server is already running. PID: " + String(pid));
            running = true;
        } else {
            // TODO: Pipe the output to system console
            runCommand(serverPath, args: ["--daemon"]);
            
            pid = checkPid();
            if (pid > 0) {
                NSLog("Emacs server started. PID: " + String(pid));
                running = true;
            } else {
                NSLog("Error starting Emacs server!");
                running = false;
            }
        }

        stateDelegate?.stateDidChange?();
    }
    
    public func stop () {
        stateDelegate?.stateWillChange?();
        
        runCommand(clientPath, args: ["-e", "(kill-emacs)"]);
        pid = checkPid();
        if (pid <= 0) {
            NSLog("Emacs server stopped.");
            running = false;
        } else {
            runCommand("/bin/kill", args: ["-KILL", String(pid)]);
            pid = checkPid();
            if (pid <= 0) {
                NSLog("Emacs server stopped.");
                running = false;
            } else {
                NSLog("Error stopping Emacs server!");
                running = true;
            }
        }
        
        stateDelegate?.stateDidChange?();
    }
    
    public func restart () {
        stop();
        start();
    }
    
    func checkPid () -> Int {
        let output = runCommand(clientPath, args: ["-e", "(emacs-pid)"]);
        let outputPid = output.toInt();
        
        if (outputPid != nil) {
            return outputPid!;
        } else {
            return 0;
        }
    }
    
    func runCommand (cmd: String, args: Array<String>) -> String {
        NSLog("Running: " + cmd + " " + " ".join(args));
        
        let pipe = NSPipe();
        let task = NSTask();
        
        // TODO: Fix an issue with ispell no in PATH
        task.launchPath = cmd;
        task.arguments = args;
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
}