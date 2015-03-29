//
//  ServerController.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

class ServerController : NSObject {
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var command: CommandRunner!;
    @IBOutlet weak var client: ClientController!;
    
    var running = false;
    var pid = 0;
    
    func isRunning () -> Bool {
        return running;
    }
    
    func getPid () -> Int {
        return pid;
    }
    
    @IBAction func start (sender: NSObject) {
        start();
    }
    
    func start () -> Promise {
        return checkPid().then({ (value: Value) -> Value in
            self.pid = value as Int;
            if (self.pid > 0) {
                NSLog("Emacs server is already running. PID: " + String(self.pid));
                self.running = true;
                return nil;
            } else {
                // Start Emacs daemon with a bash login shell in order for the daemon process to have
                // access to all $PATH.
                return self.command.run("/bin/bash", args: [
                    "-l", "-c",
                    self.preferenceController.read("serverPath") + " --daemon"
                ]).then({ (value: Value) -> Value in
                    // TODO: Pipe the output to system console
                    return self.checkPid();
                }).then({ (value: Value) -> Value in
                    self.pid = value as Int;
                    if (self.pid > 0) {
                        NSLog("Emacs server started. PID: " + String(self.pid));
                        self.running = true;
                    } else {
                        NSLog("Error starting Emacs server!");
                        self.running = false;
                    }

                    return nil;
                });
            }
        });
    }
    
    @IBAction func stop (sender: NSObject) {
        stop();
    }
    
    func stop () -> Promise {
        return client.eval("(kill-emacs)").then({ (value: Value) -> Value in
            return self.checkPid();
        }).then({ (value: Value) -> Value in
            self.pid = value as Int;
            if (self.pid <= 0) {
                NSLog("Emacs server stopped.");
                self.running = false;
                return nil;
            } else {
                return self.command.run("/bin/kill", args: [
                    "-KILL",
                    String(self.pid)
                ]).then({ (value: Value) -> Value in
                    return self.checkPid();
                }).then({ (value: Value) -> Value in
                    self.pid = value as Int;
                    if (self.pid <= 0) {
                        NSLog("Emacs server stopped.");
                        self.running = false;
                    } else {
                        NSLog("Error stopping Emacs server!");
                        self.running = true;
                    }
                    return nil;
                });
            }
        });
    }
    
    @IBAction func restart (sender: NSObject) {
        restart();
    }
    
    func restart () -> Promise {
        return stop().then({ (value: Value) -> Value in
            return self.start();
        });
    }
    
    func checkPid () -> Promise {
        return client.eval("(emacs-pid)").then({ (value: Value) -> Value in
            let outputPid = (value as String).toInt();
            if (outputPid != nil) {
                return outputPid!;
            } else {
                return 0;
            }
        });
    }
}