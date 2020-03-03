//
//  XyoHeuristicGetter.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/* Gets the Heuristic for the getter. If the heuristic is null, the heuristic will 
not be included in the payload
@return the Heuristic */

public protocol XyoHeuristicGetter {
    func getHeuristic () -> XyoObjectStructure?
}
