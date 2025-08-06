//
//  KeyEscape.swift
//  Gist
//
//  Created by Aleph-L9NW4F on 07/08/25.
//

import SwiftUI

struct KeyEscapePressModifer: ViewModifier {
  var handler: () -> Void
  
  func body(content: Content) -> some View {
    if #available(macOS 14.0, *) {
      content
        .onKeyPress(.escape) {
          handler()
          return .handled
        }
    } else {
      content
    }
  }
}

extension View {
  func onKeyEscapePressed(handler: @escaping () -> Void) -> some View {
    modifier(KeyEscapePressModifer(handler: handler))
  }
}
