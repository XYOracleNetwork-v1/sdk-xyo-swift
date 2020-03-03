//
//  XyoByteUtil.swift
//  sdk-objectmodel-swift
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoByteUtil {
    public static func concatAll(arrays: [[UInt8]]) -> [UInt8] {
        var masterBuffer = [UInt8]()

        for array in arrays {
            masterBuffer.append(contentsOf: array)
        }

        return masterBuffer
    }

    public static func getBestSize (size: Int) -> XyoObjectSize {
        if size + 1 <= UInt8.max {
            return XyoObjectSize.ONE
        }

        if size + 2 <= UInt16.max {
            return XyoObjectSize.TWO
        }

        if size + 4 <= UInt32.max {
            return XyoObjectSize.FOUR
        }

        return XyoObjectSize.EIGHT
    }
}
