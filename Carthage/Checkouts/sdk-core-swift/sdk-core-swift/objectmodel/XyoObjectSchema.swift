//
//  XyoObjectSchema.swift
//  sdk-objectmodel-swift
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoObjectSchema {
    public let id: UInt8
    public let encodingCatalogue: UInt8

    public init(id: UInt8, encodingCatalogue: UInt8) {
        self.id = id
        self.encodingCatalogue = encodingCatalogue
    }

    public func getSizeIdentifier () -> XyoObjectSize {

        // masking the first two bits to get the result
        // 0xC0 == 11000000

        if encodingCatalogue & 0xc0 == 0x00 {
            return XyoObjectSize.ONE
        }

        if encodingCatalogue & 0xc0 == 0x40 {
            return XyoObjectSize.TWO
        }

        if encodingCatalogue & 0xc0 == 0x80 {
            return XyoObjectSize.FOUR
        }

        return XyoObjectSize.EIGHT
    }

    public func getIsIterable() -> Bool {
        return encodingCatalogue & 0x20 != 0
    }

    public func getIsTypedIterable() -> Bool {
        return encodingCatalogue & 0x10 != 0
    }

    public func toByteArray () -> [UInt8] {
        return [encodingCatalogue, id]
    }

    public static func create (id: UInt8,
                               isIterable: Bool,
                               isTypedIterable: Bool,
                               sizeIdentifier: XyoObjectSize) -> XyoObjectSchema {
        let iterableByte: UInt8 = getIterableByte(isIterable: isIterable)
        let isTypedIterableByte: UInt8 = getIsTypedByte(isTyped: isTypedIterable)
        let sizeIdentifierByte: UInt8 = getSizeIdentifierByte(sizeIdentifier: sizeIdentifier)
        let encodingCatalogue: UInt8 = iterableByte | isTypedIterableByte | sizeIdentifierByte

        return XyoObjectSchema(id: id, encodingCatalogue: encodingCatalogue)
    }

    private static func getIterableByte(isIterable: Bool) -> UInt8 {
        if isIterable {
            return 0x20
        }

        return 0x00
    }

    private static func getIsTypedByte (isTyped: Bool) -> UInt8 {
        if isTyped {
            return 0x10
        }

        return 0x00
    }

    private static func getSizeIdentifierByte (sizeIdentifier: XyoObjectSize) -> UInt8 {
        switch sizeIdentifier {
        case XyoObjectSize.ONE:
            return 0x00

        case XyoObjectSize.TWO:
            return 0x40

        case XyoObjectSize.FOUR:
            return 0x80

        case XyoObjectSize.EIGHT:
            return 0xc0
        }
    }
}
