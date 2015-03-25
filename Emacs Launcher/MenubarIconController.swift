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

    let menubarIcon = NSImage(named: "Menubar Icon");
    let menubarIconLoading = NSImage(named: "Menubar Icon - Loading");
    
    func normal () {
        app.statusItemView.image = menubarIcon;
    }
    
    func loading () {
        app.statusItemView.image = menubarIconLoading;
    }
}