//
//  FloatingPanel.swift
//  Gist
//
//  Created by Uwais Alqadri on 14/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import SwiftUI
import Cocoa

class FloatingPanel: NSPanel {
  init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
    super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel], backing: backing, defer: flag)
    self.isFloatingPanel = true
    self.level = .popUpMenu
    self.collectionBehavior.insert(.fullScreenAuxiliary)
    self.titleVisibility = .hidden // Set title visibility to hidden
    self.titlebarAppearsTransparent = false
    self.isMovableByWindowBackground = false
    self.isReleasedWhenClosed = false
    
    self.standardWindowButton(.closeButton)?.isHidden = true
    self.standardWindowButton(.miniaturizeButton)?.isHidden = true
    self.standardWindowButton(.zoomButton)?.isHidden = true
  }
  
  override var canBecomeKey: Bool {
    return true
  }
  
  override var canBecomeMain: Bool {
    return true
  }
}

struct PanelContentView: View {
  @State private var searchText: String = ""
  var onSave: (String) -> Void
  
  var body: some View {
    HStack {
      if let nsImage = NSImage(named: .init("checkmark.square.fill"))?.tint(color: .white) {
        Image(nsImage: nsImage)
          .resizable()
          .frame(width: 30, height: 27)
      }
      
      TextField("Add New Gist...", text: $searchText, onCommit: {
        onSave(searchText)
        
      })
        .textFieldStyle(.plain)
        .frame(height: 50)
        .font(.system(size: 20))
        .padding(.leading, 5)
        .background(Color.clear)
    }
    .padding(.vertical, 2)
    .padding(.horizontal)
    .background(VisualEffectView(material: .contentBackground, blendingMode: .withinWindow))
    .cornerRadius(16)
  }
}

extension NSTextField {
  open override var focusRingType: NSFocusRingType {
    get { .none }
    set { }
  }
}

struct VisualEffectView: NSViewRepresentable {
  let material: NSVisualEffectView.Material
  let blendingMode: NSVisualEffectView.BlendingMode
  
  func makeNSView(context: Context) -> NSVisualEffectView {
    let visualEffectView = NSVisualEffectView()
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
    visualEffectView.state = NSVisualEffectView.State.active
    return visualEffectView
  }
  
  func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
  }
}
