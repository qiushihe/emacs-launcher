//
//  StatusItemView.swift
//  Emacs Launcher
//
//  Created by Qiushi (Billy) He on 2015-03-24.
//  Copyright (c) 2015 Billy He. All rights reserved.
//

import Cocoa

// TODO: For 10.10-only, instead of making a custom view, do:
//       statusItem.button?.window?.registerForDraggedTypes([NSFilenamesPboardType]);
//       statusItem.button?.window?.delegate = self;

class StatusItemView : NSView, NSMenuDelegate {
    var client: ClientController!;
    var statusItem: NSStatusItem!;
    var highlighted = false;
    
    var image: NSImage? {
        didSet {
            needsDisplay = true;
        }
    }
    
    // Use a dictionary to hold "valid" drops because when dragging from a Stack in the Dock
    // into a NSStatusItem's view, the performDragOperation method is never called so we have
    // a work around to call it manually from draggingEnded (see below). However the
    // consequence of that is when not dragging from a Stack in the Dock (i.e. when dragging
    // from Finder), both performDragOperation and draggingEnded are called so we'll use this
    // dictionary to ensure each drgging operation is processed only once.
    var validDrops = Dictionary<Int, Bool>();
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect);
        registerForDraggedTypes([NSFilenamesPboardType]);
    }
    
    convenience init(statusItem item: NSStatusItem) {
        var itemWidth = item.length;
        var itemHeight = NSStatusBar.systemStatusBar().thickness;
        var itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
        self.init(frame: itemRect);
        statusItem = item;
        statusItem.view = self;
    }
    
    override func drawRect(dirtyRect: NSRect) {
        statusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: highlighted);
        var icon = image;
        if (icon != nil) {
            var iconSize = icon!.size;
            var bounds = self.bounds;
            var iconX = CGFloat(roundf(Float((NSWidth(bounds) - iconSize.width) / 2)));
            var iconY = CGFloat(roundf(Float((NSHeight(bounds) - iconSize.height) / 2)));
            var iconPoint = NSMakePoint(iconX, iconY);
            icon?.drawAtPoint(iconPoint, fromRect: bounds, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0);
        }
    }
    
    func set (menu itemMenu: NSMenu) {
        itemMenu.delegate = self;
        self.menu = itemMenu;
    }
    
    override func mouseDown(theEvent: NSEvent) {
        statusItem.popUpStatusItemMenu(menu!);
    }
    
    func menuWillOpen(menu: NSMenu) {
        highlighted = true;
        needsDisplay = true;
    }
    
    func menuDidClose(menu: NSMenu) {
        highlighted = false;
        needsDisplay = true;
    }
    
    override func draggingEntered (sender: NSDraggingInfo) -> NSDragOperation {
        validDrops[sender.draggingSequenceNumber()] = true;
        return NSDragOperation.Link;
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        if (sender != nil) {
            let location = sender!.draggingLocation();
            
            // Work around a DnD bug: http://stackoverflow.com/a/10825816
            if (NSPointInRect(location, frame)) {
                performDragOperation(sender!);
            }
        }
    }
    
    override func performDragOperation (sender: NSDraggingInfo) -> Bool {
        if (validDrops[sender.draggingSequenceNumber()] != nil) {
            let pboard = sender.draggingPasteboard();
            let files = pboard.propertyListForType(NSFilenamesPboardType) as Array<String>;
            
            // We can't use on prepareForDragOperation to filter acceptable dragged objects because
            // when dragging from a Stack in the dock into the NSStatusItem's view, the
            // prepareForDragOperation is never called. So We just have to do the filter right here
            // right before we pass the paths to Emacs client. Acceptable drops are either a single
            // directory, or any number of files.
            
            var filesCount = 0;
            var directoriesCount = 0;
            
            for path in files {
                if (isPathDirectory(path)) {
                    directoriesCount++;
                } else {
                    filesCount++;
                }
            }
            
            if (directoriesCount <= 0 && filesCount > 0) {
                client.openFiles(files);
            } else if (directoriesCount == 1 && filesCount <= 0) {
                // TODO: Implement opening new frame with folder
            } else {
                // TODO: Show error popup with message for invalid drops
            }
            
            validDrops.removeValueForKey(sender.draggingSequenceNumber());
        }

        return true;
    }
    
    func isPathDirectory (path: String) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(false);
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) {
            println(isDirectory)
        }
        return Bool(isDirectory);
    }
}