//
//  GistTableCellView.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa

final class GistTableCellView: NSTableCellView {
  
  var item: Gist?
  
  override func menu(for event: NSEvent) -> NSMenu? {
    let delete = NSMenuItem(
      title: "Delete",
      action: #selector(GistWindowController.deleteMenuItemPressed), keyEquivalent: ""
    )
    delete.representedObject = item
    let menu = NSMenu()
    menu.addItem(delete)
    return menu
  }
  
}
