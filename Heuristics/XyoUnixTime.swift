//
//  XyoUnixTime.swift
//  XYO
//
//  Created by Carter Harrison on 3/26/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift
import sdk_objectmodel_swift

struct XyoUnixTime: XyoHueresticGetter {
    func getHeuristic() -> XyoObjectStructure? {
        let time: Double = NSDate().timeIntervalSince1970
        let timeAsMilliseconds = UInt64(time * 1000)

        return XyoObjectStructure.newInstance(schema: XyoSchemas.UNIX_TIME, bytes: XyoBuffer().put(bits: timeAsMilliseconds))
    }
}
