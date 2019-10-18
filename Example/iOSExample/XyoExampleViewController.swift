//
//  XyoExampleViewController.swift
//  iOSExample
//
//  Created by Kevin Weiler on 10/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import sdk_xyo_swift
import sdk_core_swift

class XyoExampleViewController: UIViewController, BoundWitnessDelegate {
  func getPayloadData() -> [UInt8]? {
    let test = "Test"
    return [UInt8](test.utf8)
  }
  
  func boundWitness(started withTarget: XyoBoundWitnessTarget) {
    print("Started BW")
  }
  
  func boundWitness(completed withTarget: XyoBoundWitnessTarget, withBoundWitness: XyoBoundWitness?) {
    print("Completed BW")

  }
  
  func boundWitness(failed withTarget: XyoBoundWitnessTarget?, withError: XyoError) {
    print("Errored BW")

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let builder = XyoNodeBuilder()
    builder.setBoundWitnessDelegate(self)
    do {
      let node = try builder.build()
      let bleNetwork = node.networks["ble"] as? XyoBleNetwork
      bleNetwork?.client.scan = true
    }
    catch {
      print("Caught Error")
    }
// start scanning
  
    
  }
}
