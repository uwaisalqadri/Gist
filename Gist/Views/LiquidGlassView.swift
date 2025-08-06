//
//  LiquidGlassView.swift
//  Gist
//
//  Created by Aleph-L9NW4F on 07/08/25.
//

import SwiftUI

struct LiquidGlassView: NSViewRepresentable {
  let cornerRadius: CGFloat
  
  func makeNSView(context: Context) -> NSVisualEffectView {
    let visualEffectView = NSVisualEffectView()
    
    if #available(macOS 11.0, *) {
      visualEffectView.material = .hudWindow
      visualEffectView.blendingMode = .behindWindow
    } else {
      visualEffectView.material = .hudWindow
      visualEffectView.blendingMode = .behindWindow
    }
    
    visualEffectView.state = .active
    visualEffectView.wantsLayer = true
    
    let layer = visualEffectView.layer!
    layer.cornerCurve = .continuous
    layer.borderWidth = 1
    layer.borderColor = NSColor.white.withAlphaComponent(0.3).cgColor
    layer.cornerRadius = cornerRadius
    
    let shadowLayer = CALayer()
    shadowLayer.shadowColor = NSColor.black.cgColor
    shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
    shadowLayer.shadowRadius = 10
    shadowLayer.shadowOpacity = 0.2
    shadowLayer.backgroundColor = NSColor.clear.cgColor
    shadowLayer.cornerRadius = cornerRadius
    shadowLayer.cornerCurve = .continuous
    layer.insertSublayer(shadowLayer, at: 0)
    
    return visualEffectView
  }
  
  func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    if let shadowLayer = nsView.layer?.sublayers?.first {
      shadowLayer.frame = nsView.bounds
    }
  }
}
