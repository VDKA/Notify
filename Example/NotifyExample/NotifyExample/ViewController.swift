//
//  ViewController.swift
//  NotifyExample
//
//  Created by Ethan Jackwitz on 4/22/16.
//  Copyright © 2016 Tappr. All rights reserved.
//

import UIKit
import Notify

class ViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var notifyTextField: UITextField!
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  @IBAction func didPressPresent() {
    let title: String
    switch notifyTextField.text {
    case let text? where !text.characters.isEmpty:
      title = text
    default:
      title = "Hello world!"
    }
    Notify(title: title).present(dismiss: .After(1.8))
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    didPressPresent()
    return true
  }
}

extension UINavigationController {
  public override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle() ?? .Default
  }
  
  public override func prefersStatusBarHidden() -> Bool {
    return topViewController?.prefersStatusBarHidden() ?? false
  }
}
