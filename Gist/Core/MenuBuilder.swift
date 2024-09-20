//
//  MenuBuilder.swift
//  Gist
//
//  Created by Uwais Alqadri on 20/09/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa
import SwiftUI

class MenuBuilder {
  private var menu = NSMenu()
  
  @discardableResult
  func addGistItems(from gists: [Gist], action: Selector) -> MenuBuilder {
    createMenuItems(for: gists, action: action).forEach(menu.addItem)
    return self
  }
  
  @discardableResult
  func addMenuItem(title: String, action: Selector, keyEquivalent: String, modifiers: NSEvent.ModifierFlags = [.control, .command]) -> MenuBuilder {
    let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
    menuItem.keyEquivalentModifierMask = modifiers
    menu.addItem(menuItem)
    return self
  }
  
  @discardableResult
  func addLaunchAtStartupItem(isEnabled: Bool, action: Selector) -> MenuBuilder {
    let launchAtStartupItem = NSMenuItem(title: "Launch at startup", action: action, keyEquivalent: "")
    launchAtStartupItem.state = isEnabled ? .on : .off
    menu.addItem(launchAtStartupItem)
    return self
  }
  
  @discardableResult
  func addSeparator() -> MenuBuilder {
    menu.addItem(NSMenuItem.separator())
    return self
  }
  
  @discardableResult
  func addQuitItem() -> MenuBuilder {
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate), keyEquivalent: ""))
    return self
  }
  
  func build() -> NSMenu {
    return menu
  }
}

extension MenuBuilder {
  private func createMenuItems(for gists: [Gist], action: Selector) -> [NSMenuItem] {
    return gists.map { createMenuItem(for: $0, action: action) }
  }
  
  private func createMenuItem(for gist: Gist, action: Selector) -> NSMenuItem {
    let menuItem = NSMenuItem(title: gist.title, action: action, keyEquivalent: "")
    menuItem.representedObject = gist
    
    if gist.isCompleted {
      menuItem.attributedTitle = createAttributedString(for: gist.title)
    }
    
    return menuItem
  }
  
  private func createAttributedString(for title: String) -> NSAttributedString {
    let attributes: [NSAttributedString.Key: Any] = [
      .strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue,
      .font: NSFont.menuBarFont(ofSize: NSFont.systemFontSize)
    ]
    
    return NSAttributedString(string: title, attributes: attributes)
  }
}
