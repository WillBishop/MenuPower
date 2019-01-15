//
//  AppDelegate.swift
//  MenuPower
//
//  Created by Luka Kerr on 2/4/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let popover = NSPopover()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var lowerPercentageButton = NSMenuItem()
    var startAtLogin = NSMenuItem()
    var shouldShowLowerPercentage = UserDefaults.standard.bool(forKey: "shouldShowLowerPercentage"){
        didSet{
            UserDefaults.standard.set(shouldShowLowerPercentage, forKey: "shouldShowLowerPercentage")
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard var battery = getBattery() else {
            NSApplication.shared.terminate(self)
            return
        }
        battery = battery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var button = statusItem.button else {return}
        button.title = "🎧 " + battery.trimmingCharacters(in: .whitespacesAndNewlines)
        button.target = self
        let menu = NSMenu()
        
        lowerPercentageButton = NSMenuItem(title: "Display Lower Percentage", action: #selector(displayLowestPercentage), keyEquivalent: "L")
        lowerPercentageButton.state = shouldShowLowerPercentage ? .on : .off
        if shouldShowLowerPercentage{
            showLowestPercentage(inButton: button, fromBattery: battery)
        }
        menu.addItem(lowerPercentageButton)
        startAtLogin = NSMenuItem(title: "Start At Login", action: #selector(toggleStartAtLogin), keyEquivalent: "S")
        startAtLogin.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(startAtLogin)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit MenuPower", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q"))
        statusItem.menu = menu
        
        var batteryTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateBattery), userInfo: nil, repeats: true)
        
    }
    @objc func toggleStartAtLogin(){
        if LaunchAtLogin.isEnabled{
            LaunchAtLogin.isEnabled = false
            startAtLogin.state = .off
        } else {
            LaunchAtLogin.isEnabled = true
            startAtLogin.state = .on
        }
    }
    
    @objc func displayLowestPercentage(){
        guard let button = statusItem.button else {return}
        
        guard var battery = getBattery() else {
            NSApplication.shared.terminate(self)
            return
        }
        battery = battery.trimmingCharacters(in: .whitespacesAndNewlines)
        if lowerPercentageButton.state == .on{
            lowerPercentageButton.state = .off
            shouldShowLowerPercentage = false
            button.title = "🎧 " + battery.trimmingCharacters(in: .whitespacesAndNewlines)
            return
        }
        if lowerPercentageButton.state == .off{
            lowerPercentageButton.state = .on
            shouldShowLowerPercentage = true
        }
        showLowestPercentage(inButton: button, fromBattery: battery)
    }
    func showLowestPercentage(inButton button: NSStatusBarButton, fromBattery battery: String){
        guard var leftBattery = Int(battery.components(separatedBy: "%")[0].dropFirst(3)), var rightBattery = Int(battery.components(separatedBy: "%")[1].dropFirst(4)) else {return}
        if leftBattery > rightBattery{
            button.title = "🎧 \(rightBattery)%"
            button.target = self
        } else {
            button.title = "🎧 \(leftBattery)%"
            button.target = self
            
        }
    }
    @objc func updateBattery() {
        guard let battery = getBattery() else {
            NSApplication.shared.terminate(self)
            return
        }
        if let button = statusItem.button {
            button.title = "🎧 " + battery.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    func getBattery() -> String?
    {
        let script = Bundle.main.path(forResource: "battery", ofType: "sh")!
        //let script = "echo Hello World!"
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = [script]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return  String(data: data, encoding: String.Encoding.utf8)
    }
}
