//
//  calculatorApp.swift
//  calculator
//
//  Created by Sasha D on 19.10.24.
//

import SwiftUI

@main
struct FixedSizeApp: App {
    // Attach the AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 600, height: 600))
            window.minSize = NSSize(width: 600, height: 600)
            window.maxSize = NSSize(width: 600, height: 600)
            window.title = "Financial Calculator"
        }
    }
}

