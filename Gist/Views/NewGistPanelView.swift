//
//  FloatingPanel.swift
//  Gist
//
//  Created by Uwais Alqadri on 14/2/24.
//  Copyright © 2024 Uwais Alqadri. All rights reserved.
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
      Image(.icCheckmarkBox)
        .resizable()
        .renderingMode(.template)
        .frame(width: 23, height: 23)
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
        Image(.icXmarkCircle)
          .renderingMode(.template)
          .resizable()
          .frame(width: 17, height: 17)
          .foregroundColor(Color(NSColor.white))
      }.buttonStyle(.plain)
      
    }
    .padding(.vertical, 2)
    .padding(.horizontal)
    .background(LiquidGlassView(cornerRadius: 16))
    .clipShape(.rect(cornerRadius: 16))
    .onAppear {
      isTextFieldFocused = true
    }
    .onKeyEscapePressed(handler: onCancel)
  }
}

class FloatingPanel: NSPanel {
  weak var appDelegate: AppDelegate?
  
  init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
    super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel], backing: backing, defer: flag)
    self.isFloatingPanel = true
    self.level = .floating
    self.collectionBehavior = [.fullScreenAuxiliary, .ignoresCycle, .stationary, .canJoinAllSpaces]
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.isMovableByWindowBackground = false
    self.isReleasedWhenClosed = false
    self.backgroundColor = .clear
    self.hasShadow = false
    self.isOpaque = false
    
    self.standardWindowButton(.closeButton)?.isHidden = true
    self.standardWindowButton(.miniaturizeButton)?.isHidden = true
    self.standardWindowButton(.zoomButton)?.isHidden = true
    
    setupEventMonitoring()
  }
  
  private func setupEventMonitoring() {
    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      if event.keyCode == 53 { // Escape key
        self?.handleEscapeKey()
        return nil
      }
      return event
    }
    
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
      if event.keyCode == 53 { // Escape key
        self?.handleEscapeKey()
      }
    }
  }
  
  private func handleEscapeKey() {
    if let delegate = appDelegate {
      delegate.hideFloatingPanelWithAnimation()
    }
  }
  
  override var canBecomeKey: Bool {
    return true
  }
  
  override var canBecomeMain: Bool {
    return true
  }
  
  override func resignKey() {
    super.resignKey()
    // Don't auto-close when losing focus to maintain cross-space functionality
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
