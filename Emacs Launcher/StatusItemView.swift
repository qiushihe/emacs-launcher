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
        return NSDragOperation.Link;
    }
    
    override func prepareForDragOperation (sender: NSDraggingInfo) -> Bool {
        return true;
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        let location = sender?.draggingLocation();
        
        // Work around a DnD bug: http://stackoverflow.com/a/10825816
        if (location != nil && NSPointInRect(location!, frame)) {
            performDragOperation(sender!);
        }
    }
    
    override func performDragOperation (sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard();
        let files = pboard.propertyListForType(NSFilenamesPboardType) as Array<String>;
        
        client.openFiles(files);
        return true;
    }
}