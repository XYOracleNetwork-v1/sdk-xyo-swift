//
//  DemoViewController.swift
//  iOSExample
//
//  Created by Kevin Weiler on 10/23/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? XyoExampleViewController {
      destination.isClient = segue.identifier == "startClient"
    }

  }
}
