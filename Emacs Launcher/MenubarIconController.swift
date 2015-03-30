//
//  MenubarIconController.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-14.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

class MenubarIconController : NSObject {
    @IBOutlet weak var app: AppDelegate!;
    @IBOutlet weak var server: ServerController!;

    let menubarIcon = NSImage(named: "Menubar Icon");
    let menubarIconWorking = NSImage(named: "Menubar Icon - Working");
    let menubarIconReady = NSImage(named: "Menubar Icon - Ready");
    let menubarIconAlert = NSImage(named: "Menubar Icon - Alert");
    
    func normal () {
        if (server.isRunning()) {
            app.statusItemView.image = menubarIconReady;
        } else {
            app.statusItemView.image = menubarIcon;
        }
    }
    
    func working () {
        app.statusItemView.image = menubarIconWorking;
    }
    
    func ready () {
        app.statusItemView.image = menubarIconReady;
    }
    
    func alert () {
        app.statusItemView.image = menubarIconAlert;
    }
}