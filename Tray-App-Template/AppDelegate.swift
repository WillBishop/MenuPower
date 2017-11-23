//
//  AppDelegate.swift
//  Tray-App-Template
//
//  Created by Luka Kerr on 2/4/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
	let popover = NSPopover()
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	
	func showPopover(sender: AnyObject?) {
		NSApplication.shared.activate(ignoringOtherApps: true)
		if let button = statusItem.button {
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
		}
	}
 
	func closePopover(sender: AnyObject?) {
		popover.performClose(sender)
	}
 
	@objc func togglePopover(sender: AnyObject?) {
		if popover.isShown {
			closePopover(sender: sender)
		} else {
			showPopover(sender: sender)
		}
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		if let button = statusItem.button {
			button.image = NSImage(named: NSImage.Name(rawValue: "icon"))
			button.image?.isTemplate = true 
			button.target = self
			button.action = #selector(self.togglePopover(sender:))
		}
		popover.contentViewController = MenuViewController(nibName: NSNib.Name(rawValue: "MenuViewController"), bundle: nil)
		// Disable delay for popover - default is true
		popover.animates = false
		// When something else is clicked, close the popover
		popover.behavior = .transient
	}
	
	
}
