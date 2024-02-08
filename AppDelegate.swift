//
//  AppDelegate.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, GistWindowControllerDelegate {
  
  @IBOutlet weak var window: NSWindow!
  
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  lazy var editTodosWindowController: GistWindowController = {
    let viewController = GistWindowController(windowNibName: .init(String(describing: GistWindowController.self)))
    return viewController
  }()
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    updateStatusItem()
  }
  
  func didUpdateGists(_ controller: GistWindowController) {
    updateStatusItem()
  }
    
  override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if let item = menuItem.representedObject as? Gist {
      menuItem.state = item.isCompleted ? .on : .off
      guard let isVisible = editTodosWindowController.window?.isVisible else { return true }
      return !isVisible
    }
    return true
  }
  
  // MARK: - Setup Status Item
  
  private func updateStatusItem() {
    updateStatusItemButton()
    updateStatusItemMenu()
  }
  
  private func updateStatusItemButton() {
    guard let button = statusItem.button else { return }
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
    menu.addItem(NSMenuItem(title: "Edit gists...", action: #selector(menuEditItemPressed), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate), keyEquivalent: ""))
    
    statusItem.menu = menu
  }
  
  private func createMenuItems(for gists: [Gist]) -> [NSMenuItem] {
    var items = [NSMenuItem]()
    gists.forEach { item in
      let todo = NSMenuItem(title: item.title, action: #selector(menuTodoItemPressed), keyEquivalent: "")
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
  
  // MARK: - Menu Actions
  
  @objc private func menuTodoItemPressed(_ sender: NSMenuItem) {
    guard let item = sender.representedObject as? Gist else { return }
    item.isCompleted = !item.isCompleted
    updateStatusItem()
  }
  
  @objc private func menuEditItemPressed(_ sender: NSMenuItem) {
    NSApp.activate(ignoringOtherApps: true)
    editTodosWindowController.delegate = self
    editTodosWindowController.window?.center()
    editTodosWindowController.window?.orderFrontRegardless()
    editTodosWindowController.window?.makeFirstResponder(nil)
    editTodosWindowController.tableView.reloadData()
  }
}
