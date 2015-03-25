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
        return command.run(preferenceController.read("clientPath"), args: ["-n", "-c", "-e", launchClientCommand()]);
    }
    
    func openFiles (paths: Array<String>) {
        // Reverse the opening order so the first file is the last to be opened and thus
        // is the one the user is looking at in the end
        for path in paths.reverse() {
            openFile(path);
        }
    }
    
    func openFile (path: String) -> Promise {
        return command.run(preferenceController.read("clientPath"), args: ["-n", "-e", openFileCommand(path)]);
    }
    
    func eval (expression: String) -> Promise {
        return command.run(preferenceController.read("clientPath"), args: ["-e", expression]);
    }
    
    func launchClientCommand () -> String {
        let defaultDir = preferenceController.read("defaultDirectory")
        return "".join([
            "(progn",
            // Switch to the "*scratch*" buffer so we're not looking at some random buffers each time
            "  (switch-to-buffer \"*scratch*\")",
            
            // Ensure the newly created frame has focus.
            "  (select-frame-set-input-focus (selected-frame))",
            
            // Create and set a frame-local variable to mark the working directory of the frame
            "  (make-variable-frame-local 'working-directory)",
            "  (modify-frame-parameters nil '((working-directory . \"" + defaultDir + "\")))",
            "  (cd working-directory)",
            
            // Maximize the frame and move it to top-left position
            //"  (set-frame-parameter nil 'fullscreen 'maximized)",
            //"  (set-frame-parameter nil 'top 0)",
            //"  (set-frame-parameter nil 'left 0)",
            ")"
        ]);
    }
    
    func openFileCommand (path: String) -> String {
        return ensureFrameCommand("a-frame", body: "".join([
            "(progn",
            "  (select-frame-set-input-focus a-frame)",
            "  (find-file \"" + path + "\")",
            ")"
        ]));
    }
    
    func ensureFrameCommand (varName: String, body: String) -> String {
        return "".join([
            "(let (",
            "  (" + varName + " (if (>= 1 (list-length (frame-list)))",
            "    (make-frame '((window-system . ns)))",
            "    (nth 0 (frame-list))",
            "  ))",
            ") " + body + ")"
        ]);
    }
}