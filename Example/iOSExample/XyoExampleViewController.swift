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
  func boundWitness(started withDeviceId: String) {
    print("Started BW with \(withDeviceId)")
  }
  
  func boundWitness(completed withDeviceId: String, withBoundWitness: XyoBoundWitness?) {
    print("Completed BW with \(withDeviceId)")

  }
  
  func boundWitness(failed withDeviceId: String?, withError: XyoError) {
    print("Errored BW with \(String(describing: withDeviceId))")
  }
  
  func getPayloadData() -> [UInt8]? {
    let test = "Test"
    return [UInt8](test.utf8)
  }
  

  
  override func viewDidLoad() {
    super.viewDidLoad()
    let builder = XyoNodeBuilder()
    builder.setBoundWitnessDelegate(self)
    do {
      let node = try builder.build()
      let bleNetwork = node.networks["ble"] as? XyoBleNetwork
      bleNetwork?.client.scan = true
//      bleNetwork?.server.listen = true
    }
    catch {
      print("Caught Error")
    }
  }
}
