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
    var previous = " Not Connected\n"
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let battery = getBattery() else {
            NSApplication.shared.terminate(self)
            return
        }
        guard let button = statusItem.button else {return}
        button.target = self
        updateBattery()
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
        
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateBattery), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(bluetoothWatchdog), userInfo: nil, repeats: true)
        
    }
    @objc func bluetoothWatchdog(){
        guard let battery = self.getBattery() else {return}
        if previous.contains("Connected") && !battery.contains("Connected"){
            print("Connected")
            let notificationCenter = NSUserNotificationCenter.default
            
            let notification = NSUserNotification()
            notification.identifier = "airpods-connected + \(Date().timeIntervalSince1970)"
            notification.title = "AirPods Connected"
            notification.informativeText = battery
            notification.soundName = nil
            notificationCenter.deliver(notification)
            self.updateBattery()
            
            notificationCenter.deliver(notification)
        } else if battery.contains("Not Connected") && !previous.contains("Connected"){
            self.updateBattery()
        }
        previous = battery
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
        guard let leftBattery = Int(battery.components(separatedBy: "%")[0].dropFirst(3)), let rightBattery = Int(battery.components(separatedBy: "%")[1].dropFirst(4)) else {return}
        if leftBattery > rightBattery{
            button.title = "🎧 \(rightBattery)%"
        } else {
            button.title = "🎧 \(leftBattery)%"
        }
    }
    @objc func updateBattery() {
        guard var battery = getBattery() else {
            NSApplication.shared.terminate(self)
            return
        }
        battery = battery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let button = statusItem.button {
            if let leftBattery = Int(battery.components(separatedBy: "%")[0].dropFirst(3)), let rightBattery = Int(battery.components(separatedBy: "%")[1].dropFirst(4)){
                if leftBattery == 0 && rightBattery == 0{
                    button.title = "🎧 No Battery"
                    return
                } else if leftBattery == 0{
                    button.title = "🎧 R: \(rightBattery)%"
                    return
                }
                else if rightBattery == 0{
                    button.title = "🎧 L: \(leftBattery)%"
                    return
                }
            }
            button.title = "🎧 " + battery
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
