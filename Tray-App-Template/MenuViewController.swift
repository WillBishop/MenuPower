//
//  MenuViewController.swift
//  Tray-App-Template
//
//  Created by Luka Kerr on 2/4/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	// This is linked up to the "Quit Button" in the MenuViewController.xib
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
}
