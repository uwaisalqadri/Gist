//
//  Preference.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa

final class Preference {
  
  static let `default` = Preference()
    
  private let itemsKey = "Gists"
  private(set) var gists = [Gist]()
  
  private init() {
    if let data = UserDefaults.standard.object(forKey: itemsKey) as? Data,
      let items = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Gist] {
      gists = items
    }
  }
  
  func mark(item: Gist, isCompleted: Bool) {
    item.isCompleted = isCompleted
    synchronize()
  }
  
  func addGist(title: String) {
    let item = Gist(title: title)
    gists.append(item)
    synchronize()
  }
  
  func deleteAll() {
    gists = []
    synchronize()
  }
  
  func deleteTodoItem(at index: Int) {
    gists.remove(at: index)
    synchronize()
  }
  
  func update(title: String, forGist item: Gist) {
    item.title = title
    synchronize()
  }
  
  private func synchronize() {
    let data = NSKeyedArchiver.archivedData(withRootObject: gists)
    UserDefaults.standard.set(data, forKey: itemsKey)
  }
  
}
