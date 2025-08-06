//
//  AppDelegate.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 Uwais Alqadri. All rights reserved.
//

import Cocoa
import SwiftUI
import HotKey

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

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    updateStatusItem()
    
    addGistHotkey.keyDownHandler = { [weak self] in
      self?.showFloatingPanel()
    }
    editGistHotkey.keyDownHandler = { [weak self] in
      self?.showMainWindow()
    }

    GistHelper.registerHelperApp()
  }

  func applicationWillTerminate(_ notification: Notification) {
    GistHelper.unregisterHelperApp()
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
    updateStatusButton()
    updateStatusMenu()
  }
  
  private func updateStatusButton() {
    guard let button = statusBarItem.button else { return }
    
    let items = Preference.default.gists
    let totalCount = items.count
    let completedCount = items.filter(\.isCompleted).count
    
    button.image = .init(named: .init("checkmark.square.fill"))?.tint(color: .white)
    button.image?.size = .init(width: 20, height: 17)
    button.title = " \(completedCount)/\(totalCount)"
  }
  
  private func updateStatusMenu() {
    let isCompletedEmpty = Preference.default.gists.filter(\.isCompleted).isEmpty
    statusBarItem.menu = MenuBuilder()
      .addGistItems(from: Preference.default.gists, action: #selector(menuGistPressed))
      .addSeparator()
      .addMenuItem(title: "Add new gist", action: #selector(menuAddGistPressed), keyEquivalent: "G")
      .addMenuItem(title: "Import from Markdown...", action: #selector(menuImportPressed))
      .addMenuItem(title: "Copy completed", action: #selector(didCopyCompleted), isHidden: isCompletedEmpty)
      .addSeparator()
      .addMenuItem(title: "Open app", action: #selector(menuEditGistPressed), keyEquivalent: "E")
      .addLaunchAtStartupItem(isEnabled: GistHelper.isLaunchAtStartup, action: #selector(launchAtStartupPressed))
      .addSeparator()
      .addQuitItem()
      .build()
  }
}

// MARK: Actions
extension AppDelegate {
  @objc private func menuAddGistPressed(_ sender: NSMenuItem) {
    showFloatingPanel()
  }
  
  @objc private func menuGistPressed(_ sender: NSMenuItem) {
    guard let gist = sender.representedObject as? Gist else { return }
    gist.isCompleted.toggle()
    Preference.default.update(title: gist.title, forGist: gist)
    updateStatusItem()
  }
  
  @objc private func menuEditGistPressed(_ sender: NSMenuItem) {
    showMainWindow()
  }
  
  @objc private func didCopyCompleted(_ sender: NSMenuItem) {
    let completedGists = Preference.default.gists.filter(\.isCompleted)
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(completedGists.buildStringList(), forType: .string)
  }

  @objc private func launchAtStartupPressed(_ sender: NSMenuItem) {
    GistHelper.isLaunchAtStartup.toggle()
    GistHelper.registerHelperApp()
    sender.state = !GistHelper.isLaunchAtStartup ? .on : .off
    updateStatusMenu()
  }
  
  @objc private func menuImportPressed(_ sender: NSMenuItem) {
    let openPanel = NSOpenPanel()
    openPanel.title = "Import Markdown File"
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.allowedContentTypes = [.init(filenameExtension: "md")!]
    
    openPanel.begin { response in
      guard response == .OK, let url = openPanel.url else { return }
      
      do {
        try Preference.default.importGists(from: url)
        self.updateStatusItem()
        
        let alert = NSAlert()
        alert.messageText = "Import Successful"
        alert.informativeText = "Markdown file imported successfully!"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
      } catch {
        let alert = NSAlert()
        alert.messageText = "Import Failed"
        alert.informativeText = "Could not import markdown file: \(error.localizedDescription)"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
      }
    }
  }
}
