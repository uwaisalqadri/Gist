//
//  AppDelegate.swift
//  GistHelper
//
//  Created by Macintosh on 12/08/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let path = Bundle.main.bundlePath as NSString
    var components = path.pathComponents
    components.removeLast(3)
    components.append("MacOS")
    components.append("Gist")
    let newPath = NSString.path(withComponents: components)

    if let appURL = URL(string: newPath) {
      let configuration = NSWorkspace.OpenConfiguration()
      NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { (app, error) in
        if let error = error {
          print("Failed to launch application: \(error.localizedDescription)")
        } else {
          print("Application launched successfully.")
        }
      }
    }

    NSApp.terminate(nil)
  }
  
}
