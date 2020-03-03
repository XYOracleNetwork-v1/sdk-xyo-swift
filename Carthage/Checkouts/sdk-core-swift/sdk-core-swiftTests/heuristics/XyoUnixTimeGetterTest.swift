//
//  XyoUnixTimeGetterTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/23/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoUnixTimeGetterTest: XCTestCase {
    
    func testGetHeuristic () throws {
        let unixTime = XyoUnixTimeGetter().getHeuristic() as! XyoUnixTime
        _ = try unixTime.getUnixTime()
    }
    
}
