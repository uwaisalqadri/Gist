//
//  NewGistViewController.swift
//  Gist
//
//  Created by Uwais Alqadri on 8/2/24.
//  Copyright © 2024 github:uwaisalqadri. All rights reserved.
//

import Cocoa

protocol NewGistViewControllerDelegate: AnyObject {
  func didAddNewGist(_ controller: NewGistViewController, didAddGistWith title: String)
  func didCancelNewGist(_ controller: NewGistViewController)
}

class NewGistViewController: NSViewController, NSControlTextEditingDelegate {
  
  weak var delegate: NewGistViewControllerDelegate?
  
  func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    delegate?.didAddNewGist(self, didAddGistWith: fieldEditor.string)
    return true
  }
  
  override func cancelOperation(_ sender: Any?) {
    delegate?.didCancelNewGist(self)
  }
  
  @IBAction func didTapCancelButton(_ sender: Any) {
    delegate?.didCancelNewGist(self)
  }
}
