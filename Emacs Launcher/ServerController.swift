//
//  ServerController.swift
//  Emacs Launcher
//
//  Created by Billy He on 3/12/15.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

class ServerController : NSObject {
    @IBOutlet weak var statusMenuItem: NSMenuItem!;
    @IBOutlet weak var iconController: MenubarIconController!;
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var command: CommandRunner!;
    @IBOutlet weak var client: ClientController!;
    
    var running = false;
    var starting: Promise!;
    var stopping: Promise!;
    
    @IBAction func start (sender: NSObject) {
        start();
    }
    
    func start () -> Promise {
        if (starting == nil) {
            statusMenuItem.title = "Server Starting";
            iconController.working();
            
            starting = checkStatus().then({ (value: Value) -> Value in
                let status = value as! Dictionary<String, Value>;
                if (status["running"] as! Bool) {
                    NSLog("Emacs server is already running. PID: " + String(status["pid"] as! Int));
                    return status;
                } else {
                    // Start Emacs daemon with a bash login shell in order for the daemon process to have
                    // access to all $PATH.
                    return self.command.run("/bin/bash", args: [
                        "-l", "-c",
                        self.preferenceController.read("serverPath") + " --daemon"
                    ]).then({ (value: Value) -> Value in
                        // TODO: Pipe the output to system console
                        return self.checkStatus();
                    }).then({ (value: Value) -> Value in
                        let status = value as! Dictionary<String, Value>;
                        if (status["running"] as! Bool) {
                            NSLog("Emacs server started. PID: " + String(status["pid"] as! Int));
                        } else {
                            NSLog("Error starting Emacs server!");
                        }
                        return status;
                    });
                }
            }).then({ (value: Value) -> Value in
                let status = value as! Dictionary<String, Value>;
                self.statusMenuItem.title = "Server PID: " + String(status["pid"] as! Int);
                self.iconController.ready();
                self.starting = nil;
                return nil;
            });
        }
        
        return starting;
    }
    
    @IBAction func stop (sender: NSObject) {
        stop();
    }
    
    func stop () -> Promise {
        if (stopping == nil) {
            self.statusMenuItem.title = "Server Stopping";
            self.iconController.working();
            
            stopping = client.eval("(kill-emacs)").then({ (value: Value) -> Value in
                return self.checkStatus();
            }).then({ (value: Value) -> Value in
                let status = value as! Dictionary<String, Value>;
                if (!(status["running"] as! Bool)) {
                    NSLog("Emacs server stopped.");
                    return status;
                } else {
                    return self.command.run("/bin/kill", args: [
                        "-KILL",
                        String(status["pid"] as! Int)
                    ]).then({ (value: Value) -> Value in
                        return self.checkStatus();
                    }).then({ (value: Value) -> Value in
                        let status = value as! Dictionary<String, Value>;
                        if (!(status["running"] as! Bool)) {
                            NSLog("Emacs server stopped.");
                        } else {
                            NSLog("Error stopping Emacs server!");
                        }
                        return status;
                    });
                }
            }).then({ (value: Value) -> Value in
                let status = value as! Dictionary<String, Value>;
                self.statusMenuItem.title = "Server Not Running";
                self.iconController.normal();
                self.stopping = nil;
                return nil;
            });
        }
        
        return stopping;
    }
    
    @IBAction func restart (sender: NSObject) {
        restart();
    }
    
    func restart () -> Promise {
        return stop().then({ (value: Value) -> Value in
            return self.start();
        });
    }
    
    func checkStatus () -> Promise {
        return client.eval("(emacs-pid)").then({ (value: Value) -> Value in
            var pid = (value as! String).toInt();
            if (pid == nil) {
                pid = 0;
            }
            self.running = pid! != 0;
            return ["pid": pid!, "running": self.running] as Dictionary<String, Value>;
        });
    }
}