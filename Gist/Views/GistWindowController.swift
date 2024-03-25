//
//  GistWindowControllerDelegate.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa

protocol GistWindowControllerDelegate: AnyObject {
  func didUpdateGists(_ controller: GistWindowController)
}

class GistWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource {
  
  weak var delegate: GistWindowControllerDelegate?
  @IBOutlet var tableView: NSTableView!
  
  private var addTodoPanel: NSPanel?
  
  override func windowDidLoad() {
    super.windowDidLoad()
    setupTableView()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.doubleAction = #selector(doubleClick)
  }
  
  private func hideAddTodoPanel() {
    guard let window = window, let panel = addTodoPanel else { return }
    window.endSheet(panel)
  }
  
  // MAKR: - NSTableViewDataSource
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return Preference.default.gists.count
  }
  
  // MARK: - NSTableViewDelegate
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    let item = Preference.default.gists[row]
    guard let identifier = tableColumn?.identifier,
          let cellView = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView else {
      return nil
    }
    
    if identifier.rawValue == "TextCell", let cellView = cellView as? GistTableCellView {
      cellView.textField?.stringValue = item.title
      cellView.item = item
      
    } else if identifier.rawValue == "CheckboxCell", let cellView = cellView as? CheckboxTableCellView {
      cellView.checkboxButton.state = item.isCompleted ? .on : .off
      cellView.checkboxButton.tag = row
      cellView.checkboxButton.target = self
      cellView.checkboxButton.action = #selector(checkboxButtonStateChanged)
    }
    
    return cellView
  }
    
  // MARK: - Actions
  
  @objc private func checkboxButtonStateChanged(_ sender: NSButton) {
    let item = Preference.default.gists[sender.tag]
    Preference.default.mark(item: item, isCompleted: sender.state == .on)
    delegate?.didUpdateGists(self)
  }
  
  @IBAction private func addButtonPressed(_ sender: NSButton) {
    let newGistViewController = NewGistViewController()
    newGistViewController.delegate = self
    guard let window = window else { return }
    let panel = NSPanel(contentViewController: newGistViewController)
    var styleMask = panel.styleMask
    styleMask.remove(.resizable)
    panel.styleMask = styleMask
    self.addTodoPanel = panel
    window.beginSheet(panel)
  }
  
  @IBAction private func doubleClick(_ tableView: NSTableView) {
    let row = tableView.clickedRow
    guard let view = tableView.view(atColumn: 1, row: row, makeIfNecessary: false) as? NSTableCellView, let textField = view.textField else {
      return
    }
    textField.isEditable = true
    textField.target = self
    textField.action = #selector(todoTextFieldDidEndEditing)
    textField.tag = row
    if textField.acceptsFirstResponder {
      window?.makeFirstResponder(textField)
    }
  }
  
  @IBAction private func clearAllButtonPressed(_ sender: NSButton) {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "Are you sure you want to clear all gists from the list?"
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Yes")
    let response = alert.runModal()
    if response == NSApplication.ModalResponse.alertSecondButtonReturn {
      Preference.default.deleteAll()
      tableView.reloadData()
      delegate?.didUpdateGists(self)
    }
  }
  
  @IBAction private func todoTextFieldDidEndEditing(_ sender: NSTextField) {
    defer {
      sender.isEditable = false
    }
    let item = Preference.default.gists[sender.tag]
    Preference.default.update(title: sender.stringValue, forGist: item)
    delegate?.didUpdateGists(self)
  }
  
  @objc func deleteMenuItemPressed(_ sender: NSMenuItem) {
    if let item = sender.representedObject as? Gist,
       let index = Preference.default.gists.index(of: item) {
      
      Preference.default.deleteTodoItem(at: index)
      tableView.reloadData()
      delegate?.didUpdateGists(self)
    }
  }
  
  override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    return true
  }
  
}

extension GistWindowController: NewGistViewControllerDelegate {
  func didAddNewGist(_ controller: NewGistViewController, didAddGistWith title: String) {
    Preference.default.addGist(title: title)
    delegate?.didUpdateGists(self)
    tableView.reloadData()
    hideAddTodoPanel()
  }
  
  func didCancelNewGist(_ controller: NewGistViewController) {
    hideAddTodoPanel()
  }
}
