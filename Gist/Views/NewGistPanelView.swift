//
//  FloatingPanel.swift
//  Gist
//
//  Created by Uwais Alqadri on 14/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import SwiftUI
import Cocoa

struct NewGistPanelView: View {
  @State private var searchText: String = ""
  @FocusState private var isTextFieldFocused: Bool
  var onSave: (String) -> Void
  var onCancel: () -> Void
  
  var body: some View {
    HStack {
      Image(systemName: "text.badge.checkmark")
        .resizable()
        .frame(width: 20, height: 18)
        .foregroundColor(Color(NSColor.lightGray.withAlphaComponent(0.3)))
      
      TextField("Add new gist...", text: $searchText, onCommit: {
        onSave(searchText)
      })
        .focused($isTextFieldFocused)
        .textFieldStyle(.plain)
        .frame(height: 50)
        .font(.system(size: 20))
        .padding(.leading, 8)
        .background(Color.clear)
      
      Button(action: onCancel) {
        Image(systemName: "xmark.circle.fill")
          .resizable()
          .frame(width: 17, height: 17)
          .foregroundColor(Color(NSColor.lightGray))
      }.buttonStyle(.plain)
      
    }
    .padding(.vertical, 2)
    .padding(.horizontal)
    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
    .cornerRadius(8)
    .onAppear {
      isTextFieldFocused = true
    }
  }
}


class FloatingPanel: NSPanel {
  init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
    super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel], backing: backing, defer: flag)
    self.isFloatingPanel = true
    self.level = .popUpMenu
    self.collectionBehavior.insert(.fullScreenAuxiliary)
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = false
    self.isMovableByWindowBackground = false
    self.isReleasedWhenClosed = false
    self.backgroundColor = .clear
    
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
