//
//  XyoUnixTimeGetter.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoUnixTimeGetter: XyoHeuristicGetter {
    public func getHeuristic() -> XyoObjectStructure? {
        return XyoUnixTime.createNow()
    }
}
