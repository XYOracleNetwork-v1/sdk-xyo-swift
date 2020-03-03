//
//  XyoObjectStructure.swift
//  sdk-objectmodel-swift
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

open class XyoObjectStructure {
    private let typedSchema: XyoObjectSchema?
    var value: XyoBuffer

    public init (value: XyoBuffer) {
        self.typedSchema = nil
        self.value = value
    }

    public init (value: XyoBuffer, schema: XyoObjectSchema) {
        self.typedSchema = schema
        self.value = XyoBuffer().put(schema: schema).put(buffer: value)
    }

    public func getBuffer () -> XyoBuffer {
        return value
    }

    public func getSchema () throws -> XyoObjectSchema {
        return typedSchema ?? value.getSchema(offset: 0)
    }

    public func getValueCopy () throws -> XyoBuffer {
        let startIndex = 2 + (try getSchema()).getSizeIdentifier().rawValue + value.allowedOffset
        let endIndex = startIndex + (try getSize()) - (try getSchema()).getSizeIdentifier().rawValue
        try checkIndex(index: endIndex -  value.allowedOffset)

        return XyoBuffer(data: value, allowedOffset: startIndex, lastOffset: endIndex)
    }

    public func getSize () throws -> Int {
        let sizeOfSize = Int(try getSchema().getSizeIdentifier().rawValue)
        try checkIndex(index: sizeOfSize + 2)
        return readSizeOfObject(sizeIdentifier: (try getSchema()).getSizeIdentifier(), offset: 2)
    }

    internal func checkIndex (index: Int) throws {
        if index > value.getSize() {
            throw XyoObjectError.OUTOFINDEX
        }
    }

    func readSizeOfObject (sizeIdentifier: XyoObjectSize, offset: Int) -> Int {
        switch sizeIdentifier {
        case XyoObjectSize.ONE:
            return Int(value.getUInt8(offset: offset))
        case XyoObjectSize.TWO:
            return Int(value.getUInt16(offset: offset))
        case XyoObjectSize.FOUR:
            return Int(value.getUInt32(offset: offset))
        case XyoObjectSize.EIGHT:
            return Int(value.getUInt64(offset: offset))
        }
    }

    public static func newInstance (schema: XyoObjectSchema, bytes: XyoBuffer) -> XyoObjectStructure {
        return XyoObjectStructure(value: encode(schema: schema, bytes: bytes))
    }

    static func encode (schema: XyoObjectSchema, bytes: XyoBuffer) -> XyoBuffer {
        let buffer = XyoBuffer()
        let size = bytes.toByteArray().count
        let typeOfSize = XyoByteUtil.getBestSize(size: size)
        buffer.put(schema: XyoObjectSchema.create(id: schema.id,
                                                  isIterable: schema.getIsIterable(),
                                                  isTypedIterable: schema.getIsTypedIterable(),
                                                  sizeIdentifier: typeOfSize))

        switch typeOfSize {
        case XyoObjectSize.ONE:
            buffer.put(bits: UInt8(size + 1))
        case XyoObjectSize.TWO:
            buffer.put(bits: UInt16(size + 2))
        case XyoObjectSize.FOUR:
            buffer.put(bits: UInt32(size + 4))
        case XyoObjectSize.EIGHT:
            buffer.put(bits: UInt64(size + 8))
        }

        return buffer.put(bytes: bytes.toByteArray())
    }
}
