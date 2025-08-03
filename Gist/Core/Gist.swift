//
//  Gist.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 Uwais Alqadri. All rights reserved.
//

import Cocoa

final class Gist: NSObject, NSCoding {
  var title: String
  var isCompleted = false
  
  init(title: String) {
    self.title = title
  }
  
  init?(coder aDecoder: NSCoder) {
    self.title = (aDecoder.decodeObject(forKey: "title") as? String) ?? ""
    self.isCompleted = aDecoder.decodeBool(forKey: "isCompleted")
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(title, forKey: "title")
    aCoder.encode(isCompleted, forKey: "isCompleted")
  }
}

extension Array where Element == Gist {
  func buildStringList() -> String {
    return self.map({ "- \($0.title)" }).reversed().joined(separator: "\n")
  }
}
