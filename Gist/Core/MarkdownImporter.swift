//
//  MarkdownImporter.swift
//  Gist
//
//  Created by Claude on 8/6/25.
//  Copyright © 2025 Uwais Alqadri. All rights reserved.
//

import Foundation

final class MarkdownImporter {
  
  static func importGists(from fileURL: URL) throws -> [Gist] {
    let content = try String(contentsOf: fileURL, encoding: .utf8)
    return parseMarkdownContent(content)
  }
  
  private static func parseMarkdownContent(_ content: String) -> [Gist] {
    let lines = content.components(separatedBy: .newlines)
    var gists = [Gist]()
    
    for line in lines {
      let trimmedLine = line.trimmingCharacters(in: .whitespaces)
      
      // Parse checkbox items: - [ ] or - [x]
      if let todoItem = parseCheckboxItem(trimmedLine) {
        gists.append(todoItem)
      }
      // Parse bullet points: - item or * item
      else if let bulletItem = parseBulletPoint(trimmedLine) {
        gists.append(bulletItem)
      }
    }
    
    return gists
  }
  
  private static func parseCheckboxItem(_ line: String) -> Gist? {
    let checkboxPattern = "^-\\s*\\[([ xX])\\]\\s*(.+)$"
    guard let regex = try? NSRegularExpression(pattern: checkboxPattern),
          let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.count)) else {
      return nil
    }
    
    let checkboxRange = Range(match.range(at: 1), in: line)!
    let titleRange = Range(match.range(at: 2), in: line)!
    
    let isCompleted = String(line[checkboxRange]).lowercased() == "x"
    let title = String(line[titleRange]).trimmingCharacters(in: .whitespaces)
    
    guard !title.isEmpty else { return nil }
    
    let gist = Gist(title: title)
    gist.isCompleted = isCompleted
    return gist
  }
  
  private static func parseBulletPoint(_ line: String) -> Gist? {
    let bulletPattern = "^[-*]\\s+(.+)$"
    guard let regex = try? NSRegularExpression(pattern: bulletPattern),
          let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.count)) else {
      return nil
    }
    
    let titleRange = Range(match.range(at: 1), in: line)!
    let title = String(line[titleRange]).trimmingCharacters(in: .whitespaces)
    
    guard !title.isEmpty else { return nil }
    
    return Gist(title: title)
  }
}