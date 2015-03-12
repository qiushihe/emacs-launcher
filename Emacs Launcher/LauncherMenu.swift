//
//  LauncherMenu.swift
//  Emacs Launcher
//
//  Created by Billy He on 2015-03-12.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

public class LauncherMenu: NSMenu {
    public required init(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    public override init () {
        super.init(title: "Emacs Launcher Menu");
    }
}