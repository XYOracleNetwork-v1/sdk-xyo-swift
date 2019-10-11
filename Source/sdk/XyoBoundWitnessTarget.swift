//
//  XyoBoundWitnessTarget.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

protocol XyoBoundWitnessTarget {
  //this is where people provide additional payload data if they want.
  //we will need helpers to help people build the byte arrays
  var payloadCallback: (() -> [UInt8])? { get set }
  
  //accept boundwitnesses that have bridges payloads
  var acceptBridging: Bool { get set }
  
  //when auto boundwitnessing, should we bridge our chain
  var autoBridge: Bool {get set}
}

extension XyoBoundWitnessTarget {
  var payloadCallback: (() -> [UInt8])? {
    get { return nil }
    set { }
  }
}
