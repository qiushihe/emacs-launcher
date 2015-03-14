//
//  ClientController.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-13.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

public class ClientController : NSObject {
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var command: CommandRunner!;

    var launchCommand: String!;
    
    public func start () {
        command.runCommandWithoutOutput(preferenceController.read("clientPath"), args: ["-n", "-c", "-e", ensureLaunchCommand()]);
    }
    
    public func eval (expression: String) -> String {
        return command.runCommand(preferenceController.read("clientPath"), args: ["-e", expression]);
    }
    
    func ensureLaunchCommand () -> String {
        if (launchCommand == nil) {
            let homeDirectory = command.runCommand("/bin/bash", args: ["-c", "echo $HOME"]);
            launchCommand = "(progn" +
                "  (switch-to-buffer \"*scratch*\")" +
                "  (select-frame-set-input-focus (selected-frame))" +
                "  (make-variable-frame-local 'working-directory)" +
                "  (modify-frame-parameters nil '((working-directory . \"" + homeDirectory + "\")))" +
                "  (cd working-directory)" +
                "  (set-frame-parameter nil 'fullscreen 'maximized)" +
                "  (set-frame-parameter nil 'top 0)" +
                "  (set-frame-parameter nil 'left 0)" +
            ")";
        }
        
        return launchCommand;
    }
}