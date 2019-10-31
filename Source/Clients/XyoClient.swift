//
//  XyoClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

public protocol XyoClient: XyoBoundWitnessTarget, XyoHeuristicGetter {
  var pollingInterval: Int {get set}
  var scan: Bool {get set}
  var autoBoundWitness: Bool {get set}
  var knownBridges: [String] {get set}
}
