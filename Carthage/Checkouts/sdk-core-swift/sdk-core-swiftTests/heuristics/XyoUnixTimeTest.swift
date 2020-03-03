//
//  XyoUnixTimeTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/23/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoUnixTimeTest: XCTestCase {
    
    func testUnixTimeGetValue () throws {
        let unixTime = XyoUnixTime(value: XyoBuffer(data : [0x00, 0x14, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05]))
        let time = try unixTime.getUnixTime()
        
        XCTAssertEqual(time, 5)
    }

}
