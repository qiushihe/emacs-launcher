//
//  ServerController.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

public class ServerController : NSObject {
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var command: CommandRunner!;
    @IBOutlet weak var client: ClientController!;
    @IBOutlet weak var menu: LauncherMenu!;
    
    var running = false;
    var pid = 0;
    
    public func isRunning () -> Bool {
        return running;
    }
    
    public func getPid () -> Int {
        return pid;
    }
    
    public func start () {
        pid = checkPid();
        if (pid > 0) {
            NSLog("Emacs server is already running. PID: " + String(pid));
            running = true;
        } else {
            // Start Emacs daemon with a bash login shell in order for the daemon process to have
            // access to all $PATH.
            // TODO: Pipe the output to system console
            command.runCommandWithoutOutput("/bin/bash", args: ["-l", "-c", preferenceController.read("serverPath") + " --daemon"]);
            
            pid = checkPid();
            if (pid > 0) {
                NSLog("Emacs server started. PID: " + String(pid));
                running = true;
            } else {
                NSLog("Error starting Emacs server!");
                running = false;
            }
        }
        
        menu.updateMenu();
    }
    
    public func stop () {
        client.eval("(kill-emacs)");
        pid = checkPid();
        if (pid <= 0) {
            NSLog("Emacs server stopped.");
            running = false;
        } else {
            command.runCommandWithoutOutput("/bin/kill", args: ["-KILL", String(pid)]);
            pid = checkPid();
            if (pid <= 0) {
                NSLog("Emacs server stopped.");
                running = false;
            } else {
                NSLog("Error stopping Emacs server!");
                running = true;
            }
        }
        
        menu.updateMenu();
    }
    
    public func restart () {
        stop();
        start();
    }
    
    func checkPid () -> Int {
        let output = client.eval("(emacs-pid)");
        let outputPid = output.toInt();
        
        if (outputPid != nil) {
            return outputPid!;
        } else {
            return 0;
        }
    }
}