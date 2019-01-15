//
//  Popover.swift
//  Tray-App-Template
//
//  Created by Luka Kerr on 18/6/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class Popover: NSView {

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
	
	override func viewDidMoveToWindow() {
		
		guard let frameView = window?.contentView?.superview else {
			return
		}
		
		let backgroundView = NSView(frame: frameView.bounds)
		backgroundView.wantsLayer = true
		backgroundView.layer?.backgroundColor = NSColor(red: 0.21, green: 0.24, blue: 0.28, alpha: 1).cgColor
		backgroundView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
		
		frameView.addSubview(backgroundView, positioned: .below, relativeTo: frameView)
		
	}
	
}
