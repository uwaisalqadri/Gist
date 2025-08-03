//
//  Helper.swift
//  Gist
//
//  Created by Uwais Alqadri on 20/09/24.
//  Copyright © 2024 Uwais Alqadri. All rights reserved.
//

import Foundation
import ServiceManagement

/// Representation of GistHelper Module
struct GistHelper {
  static let identifier = "com.uwaisalqadri.app.gist.helper"
  
  private init() {}
  
  static var isLaunchAtStartup: Bool {
    get { UserDefaults.standard.bool(forKey: "launchAtStartup") }
    set { UserDefaults.standard.set(newValue, forKey: "launchAtStartup") }
  }
  
  static func registerHelperApp() {
    let loginItem = SMAppService.loginItem(identifier: identifier)
    
    do {
      try loginItem.register()
      print("Helper app registered successfully.")
    } catch {
      print("Failed to register helper app: \(error.localizedDescription)")
    }
  }
  
  static func unregisterHelperApp() {
    let loginItem = SMAppService.loginItem(identifier: identifier)
    
    do {
      try loginItem.unregister()
      print("Helper app unregistered successfully.")
    } catch {
      print("Failed to unregister helper app: \(error.localizedDescription)")
    }
  }
}
