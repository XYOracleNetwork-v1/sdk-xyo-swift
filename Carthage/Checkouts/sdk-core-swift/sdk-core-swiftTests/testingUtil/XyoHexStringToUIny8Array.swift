//
//  XyoHexStringToUIny8Array.swift
//  sdk-objectmodel-swiftTests
//
//  Created by Carter Harrison on 1/23/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

extension StringProtocol {
    func hexStringToBytes () -> [UInt8] {
        var start = startIndex
        return stride(from: 0, to: count, by: 2).compactMap {  _ in
            let end = index(start, offsetBy: 2, limitedBy: endIndex) ?? endIndex
            defer { start = end }
            return UInt8(self[start..<end], radix: 16)
        }
    }
}
