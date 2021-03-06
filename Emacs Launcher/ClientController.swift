//
//  ClientController.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-13.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Foundation

class ClientController : NSObject {
    @IBOutlet weak var preferenceController: PreferenceController!;
    @IBOutlet weak var command: CommandRunner!;

    func launchClient () -> Promise {
        return command.run(preferenceController.read("clientPath"), args: [
            "-n", "-c", "-e",
            launchClientCommand(maximizeFrame: preferenceController.readBool("maximizeNewFrameAfterLaunch"))
        ]);
    }
    
    @IBAction func openScratch (sender: NSObject) {
        openScratch();
    }
    
    func openScratch () -> Promise {
        return command.run(preferenceController.read("clientPath"), args: [
            "-n", "-e",
            openScratchCommand(maximizeFrame: preferenceController.readBool("maximizeNewFilesFrames"))
        ]);
    }
    
    func openFiles (paths: Array<String>) -> Promise {
        var promises = Array<Promise>();
        
        // Reverse the opening order so the first file is the last to be opened and thus
        // is the one the user is looking at in the end
        for path in paths.reverse() {
            promises.append(command.run(preferenceController.read("clientPath"), args: [
                "-n", "-e",
                openFileCommand(path,
                    inNewFrame: preferenceController.readBool("alwaysCreateNewFrameForDroppedFiles"),
                    forFolder: false,
                    maximizeFrame: preferenceController.readBool("maximizeNewFilesFrames"))
            ]));
        }
        
        return Craft.all(promises);
    }
    
    func openFolder (path: String) -> Promise {
        return command.run(preferenceController.read("clientPath"), args: [
            "-n", "-e",
            openFileCommand(path,
                inNewFrame: true,
                forFolder: true,
                maximizeFrame: preferenceController.readBool("maximizeNewFolderFrames"))
        ]);
    }
    
    func eval (expression: String) -> Promise {
        return command.run(preferenceController.read("clientPath"), args: [
            "-e", expression
        ]);
    }
    
    func openScratchCommand (#maximizeFrame: Bool) -> String {
        var commands = ["(progn"];
        
        commands += [
            "(switch-to-buffer \"*scratch*\")",
            "(select-frame-set-input-focus (selected-frame))"
        ];
        
        if (maximizeFrame) {
            commands += [maximizeFrameCommand()];
        }
        
        commands += [")"];
        
        return ensureFrameCommand("a-frame", body: " ".join(commands), alwaysNew: true);
    }
    
    func launchClientCommand (#maximizeFrame: Bool) -> String {
        let defaultDir = preferenceController.read("defaultDirectory");
        var commands = ["(progn"];
        
        commands += [
            "(switch-to-buffer \"*scratch*\")",
            "(select-frame-set-input-focus (selected-frame))",
            setFrameWorkingDirectoryCommand(defaultDir)
        ];
        
        if (maximizeFrame) {
            commands += [maximizeFrameCommand()];
        }
        
        commands += [")"];
        
        return " ".join(commands);
    }
    
    func openFileCommand (path: String, inNewFrame: Bool, forFolder: Bool, maximizeFrame: Bool) -> String {
        var commands = [
            "(progn",
            "(select-frame-set-input-focus a-frame)"
        ];
        
        if (forFolder) {
            commands += [setFrameWorkingDirectoryCommand(path)];
        }
        
        if (inNewFrame && maximizeFrame) {
            commands += [maximizeFrameCommand()];
        }
        
        commands += [
            "(find-file \"" + path + "\")",
            ")"
        ];
        
        return ensureFrameCommand("a-frame", body: " ".join(commands), alwaysNew: inNewFrame);
    }
    
    func setFrameWorkingDirectoryCommand (path: String) -> String {
        return " ".join([
            "(progn",
            "(make-variable-frame-local 'working-directory)",
            "(modify-frame-parameters nil '((working-directory . \"" + path + "\")))",
            "(cd working-directory)",
            ")"
        ]);
    }
    
    func ensureFrameCommand (varName: String, body: String, alwaysNew: Bool) -> String {
        if (alwaysNew) {
            return " ".join([
                "(let (",
                "(" + varName + " (make-frame '((window-system . ns))))",
                ") " + body + ")"
            ]);
        } else {
            return " ".join([
                "(let (",
                "(" + varName + " (if (>= 1 (list-length (frame-list)))",
                "(make-frame '((window-system . ns)))",
                "(nth 0 (frame-list))",
                "))",
                ") " + body + ")"
            ]);
        }
    }
    
    func maximizeFrameCommand () -> String {
        return " ".join([
            "(progn",
            "(set-frame-parameter nil 'fullscreen 'maximized)",
            "(set-frame-parameter nil 'top 0)",
            "(set-frame-parameter nil 'left 0)",
            ")"
        ]);
    }
}