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
    
    public override init () {
        super.init();
        running = false;
        pid = 0;
    }
    
    public func isRunning () -> Bool {
        return running;
    }
    
    public func getPid () -> Int {
        return pid;
    }
    
    public func start () {
        stateDelegate?.stateWillChange?();
        running = true;
        pid = 42;
        stateDelegate?.stateDidChange?();
    }
    
    public func stop () {
        stateDelegate?.stateWillChange?();
        running = false;
        pid = 0;
        stateDelegate?.stateDidChange?();
    }
    
    public func restart () {
        stop();
        start();
    }
}