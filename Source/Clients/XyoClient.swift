//
//  XyoClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

protocol XyoClient: XyoBoundWitnessTarget {
  var scan: Bool {get set}
}
