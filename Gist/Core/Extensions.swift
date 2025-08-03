//
//  Extensions.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 Uwais Alqadri. All rights reserved.
//

import Cocoa

extension NSImage {
  func tint(color: NSColor) -> NSImage {
    let image = self.copy() as! NSImage
    image.lockFocus()
    color.set()
    
    let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
    imageRect.fill(using: .sourceAtop)
    
    image.unlockFocus()
    return image
  }
}
