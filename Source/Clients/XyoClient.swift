//
//  XyoClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

protocol XyoClient: XyoBoundWitnessTarget {
  
  //automatically does boundwitnesses with remote servers
  //we need to add settings for how often to try and retries
  var autoBoundWitness: Bool {get set}
  
  //starts a boundwitness interaction with a known remote server
  //if bridge is true, then it will try to offload blocks to devices
  func initiateBoundWitness(device: XyoNetworkDevice, bridge: Bool)
  
}
