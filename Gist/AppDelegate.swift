//
//  AppDelegate.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa
import SwiftUI
import HotKey
import ServiceManagement

@main
class AppDelegate: NSObject, NSApplicationDelegate, GistWindowControllerDelegate {
  
  @IBOutlet weak var window: NSWindow!
  var newEntryPanel: FloatingPanel!
  
  private let addGistHotkey = HotKey(key: .g, modifiers: [.control, .command])
  private let editGistHotkey = HotKey(key: .e, modifiers: [.control, .command])
  private let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  private lazy var editTodosWindowController: GistWindowController = {
    GistWindowController(
      windowNibName: .init(String(describing: GistWindowController.self))
    )
  }()

  private var isLaunchAtStartup: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "launchAtStartup")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "launchAtStartup")
    }
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    updateStatusItem()
    
    addGistHotkey.keyDownHandler = { [weak self] in
      self?.showFloatingPanel()
    }
    editGistHotkey.keyDownHandler = { [weak self] in
      self?.showMainWindow()
    }

    let helperAppIdentifier = "com.nazaralwi.GistHelper"
    SMLoginItemSetEnabled(helperAppIdentifier as CFString, true)
  }

  func applicationWillTerminate(_ notification: Notification) {
    let helperAppIdentifier = "com.nazaralwi.GistHelper"
    SMLoginItemSetEnabled(helperAppIdentifier as CFString, false)
  }

  private func showFloatingPanel() {
    newEntryPanel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 512, height: 80), backing: .buffered, defer: false)
    
    let contentView = NewGistPanelView(
      onSave: { newGist in
        guard !newGist.isEmpty else {
          self.newEntryPanel.close()
          return
        }
        Preference.default.addGist(title: newGist)
        self.updateStatusItem()
        self.newEntryPanel.close()
      },
      onCancel: {
        self.newEntryPanel.close()
      }
    ).edgesIgnoringSafeArea(.top)
    
    let hostedView = NSHostingView(rootView: contentView)
    hostedView.layer?.cornerRadius = 16
    newEntryPanel.contentView = hostedView
    
    newEntryPanel.center()
    newEntryPanel.orderFront(nil)
    newEntryPanel.makeKey()
  }
  
  private func showMainWindow() {
    NSApp.activate(ignoringOtherApps: true)
    editTodosWindowController.delegate = self
    editTodosWindowController.window?.center()
    editTodosWindowController.window?.orderFrontRegardless()
    editTodosWindowController.window?.makeFirstResponder(nil)
    editTodosWindowController.tableView.reloadData()
  }
  
  func didUpdateGists(_ controller: GistWindowController) {
    updateStatusItem()
  }
}

// MARK: Menu
extension AppDelegate {
  override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if let item = menuItem.representedObject as? Gist {
      menuItem.state = item.isCompleted ? .on : .off
      guard let isVisible = editTodosWindowController.window?.isVisible else { return true }
      return !isVisible
    }
    return true
  }
  
  private func updateStatusItem() {
    updateStatusItemButton()
    updateStatusItemMenu()
  }
  
  private func updateStatusItemButton() {
    guard let button = statusBarItem.button else { return }
    let totalCount = Preference.default.gists.count
    let completedCount = Preference.default.gists.filter { $0.isCompleted }.count
    button.image = .init(named: .init("checkmark.square.fill"))?.tint(color: .white)
    button.image?.size = .init(width: 20, height: 17)
    button.title = " \(completedCount)/\(totalCount)"
  }
  
  private func updateStatusItemMenu() {
    let menu = NSMenu()
    createMenuItems(for: Preference.default.gists).forEach(menu.addItem)
    menu.addItem(NSMenuItem.separator())
    
    let addItem = NSMenuItem(title: "Add new gist", action: #selector(menuAddGistPressed), keyEquivalent: "G")
    addItem.keyEquivalentModifierMask = [.control, .command]
    menu.addItem(addItem)
    
    let editItem = NSMenuItem(title: "Edit gists...", action: #selector(menuEditGistPressed), keyEquivalent: "E")
    editItem.keyEquivalentModifierMask = [.control, .command]
    menu.addItem(editItem)

    menu.addItem(NSMenuItem.separator())
    let launchAtStartupItem = NSMenuItem(title: "Launch at startup", action: #selector(launchAtStartupPressed), keyEquivalent: "")
    launchAtStartupItem.state = isLaunchAtStartup ? .on : .off
    menu.addItem(launchAtStartupItem)

    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate), keyEquivalent: ""))
    
    statusBarItem.menu = menu
  }
  
  private func createMenuItems(for gists: [Gist]) -> [NSMenuItem] {
    var items = [NSMenuItem]()
    gists.forEach { item in
      let todo = NSMenuItem(title: item.title, action: #selector(menuGistPressed), keyEquivalent: "")
      todo.representedObject = item
      if item.isCompleted {
        let attributes: [NSAttributedStringKey: Any] = [
          .strikethroughStyle: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue),
          .font: NSFont.menuBarFont(ofSize: 0)
        ]
        let attributedString = NSAttributedString(string: item.title, attributes: attributes)
        todo.attributedTitle = attributedString
      }
      items.append(todo)
    }
    return items
  }
}

// MARK: Actions
extension AppDelegate {
  @objc private func menuAddGistPressed(_ sender: NSMenuItem) {
    showFloatingPanel()
  }
  
  @objc private func menuGistPressed(_ sender: NSMenuItem) {
    guard let item = sender.representedObject as? Gist else { return }
    item.isCompleted = !item.isCompleted
    Preference.default.update(title: item.title, forGist: item)
    updateStatusItem()
  }
  
  @objc private func menuEditGistPressed(_ sender: NSMenuItem) {
    showMainWindow()
  }

  @objc private func launchAtStartupPressed(_ sender: NSMenuItem) {
    let helperAppIdentifier = "com.nazaralwi.GistHelper"
    let shouldEnable = !isLaunchAtStartup

    SMLoginItemSetEnabled(helperAppIdentifier as CFString, shouldEnable)

    isLaunchAtStartup = shouldEnable

    sender.state = shouldEnable ? .on : .off
  }
}
