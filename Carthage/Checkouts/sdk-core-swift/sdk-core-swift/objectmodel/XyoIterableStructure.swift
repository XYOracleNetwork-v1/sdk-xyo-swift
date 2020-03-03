//
//  XyoIterableStructure.swift
//  sdk-objectmodel-swift
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

open class XyoIterableStructure: XyoObjectStructure {
    private var globalSchema: XyoObjectSchema?

    public func getNewIterator () throws -> XyoObjectIterator {
        return try XyoObjectIterator(currentOffset: readOwnHeader(), structure: self, isTyped: globalSchema != nil)
    }

    public func getCount () throws -> Int {
        let sizeIt = try self.getNewIterator()
        var index = 0

        while try sizeIt.hasNext() {
            index += 1
            try sizeIt.next()
        }

        return index
    }

    public func get (index: Int) throws -> XyoObjectStructure {
        let iterable = try getNewIterator()
        var structIndex = 0

        while try iterable.hasNext() {
            let item = try iterable.next()

            if index == structIndex {
                return item
            }

            structIndex += 1
        }

        throw XyoObjectError.OUTOFINDEX
    }

    public func get (objectId: UInt8) throws -> [XyoObjectStructure] {
        let iterator = try getNewIterator()
        var itemsThatFollowId = [XyoObjectStructure]()

        while try iterator.hasNext() {
            let item = try iterator.next()

            if try item.getSchema().id == objectId {
                itemsThatFollowId.append(item)
            }

        }

       return itemsThatFollowId
    }

    func readItemAtOffset (offset: Int) throws -> XyoObjectStructure {
        if globalSchema == nil {
            return try readItemUntyped(offset: offset)
        }

        return try readItemTyped(offset: offset, schemaOfItem: globalSchema!)
    }

    private func readItemUntyped (offset: Int) throws -> XyoObjectStructure {
        let schemaOfItem =  value.getSchema(offset: offset)
        let sizeOfObject = readSizeOfObject(sizeIdentifier: schemaOfItem.getSizeIdentifier(), offset: offset + 2)

        if sizeOfObject == 0 {
            throw XyoObjectError.SIZEZERO
        }

        let start = offset + value.allowedOffset
        let end = offset + 2 + sizeOfObject + value.allowedOffset

        try checkIndex(index: (end - value.allowedOffset))

        let object = XyoBuffer(data: value, allowedOffset: start, lastOffset: end)

        if schemaOfItem.getIsIterable() {
            return XyoIterableStructure(value: object)
        }

        return XyoObjectStructure(value: object)
    }

    private func readItemTyped (offset: Int, schemaOfItem: XyoObjectSchema) throws -> XyoObjectStructure {
        let sizeOfObject = readSizeOfObject(sizeIdentifier: schemaOfItem.getSizeIdentifier(), offset: offset)

        if sizeOfObject == 0 {
            throw XyoObjectError.SIZEZERO
        }

        let start = offset + value.allowedOffset
        let end = sizeOfObject + offset + value.allowedOffset

        try checkIndex(index: (end - value.allowedOffset))

        let object = XyoBuffer(data: value, allowedOffset: start, lastOffset: end)

        if schemaOfItem.getIsIterable() {
            return XyoIterableStructure(value: object, schema: schemaOfItem)
        }

        return XyoObjectStructure(value: object, schema: schemaOfItem)
    }

    private func readOwnHeader () throws -> Int {
        try checkIndex(index: 2)
        let setHeader = value.getSchema(offset: 0)

        try checkIndex(index: 2 + setHeader.getSizeIdentifier().rawValue)
        let totalSize = readSizeOfObject(sizeIdentifier: setHeader.getSizeIdentifier(), offset: 2)

        if !setHeader.getIsIterable() {
            throw XyoObjectError.NOTITERABLE
        }

        if setHeader.getIsTypedIterable() && totalSize != setHeader.getSizeIdentifier().rawValue {
            globalSchema = value.getSchema(offset: setHeader.getSizeIdentifier().rawValue + 2)
            return 4 + setHeader.getSizeIdentifier().rawValue
        }

        return 2 + setHeader.getSizeIdentifier().rawValue
    }

    // todo make this not copy
    public func addElement (element: XyoObjectStructure) throws {
        let buffer = try getValueCopy()

        if try self.getSchema().getIsTypedIterable() {
            _ = try readOwnHeader()

            if try element.getSchema().id == (self.globalSchema?.id) {
                buffer.put(buffer: element.getBuffer().copyRangeOf(from: 2, toEnd: try element.getSize() + 2))
                value = XyoObjectStructure.encode(schema: try self.getSchema(), bytes: buffer)
                return
            }

            throw XyoObjectError.WRONGTYPE
        }

        buffer.put(buffer: element.getBuffer())

        value = XyoObjectStructure.encode(schema: try self.getSchema(), bytes: buffer)
    }

    public class XyoObjectIterator {
        private var isTyped: Bool
        private var structure: XyoIterableStructure
        private var currentOffset: Int = 0

        public init(currentOffset: Int, structure: XyoIterableStructure, isTyped: Bool) {
            self.structure = structure
            self.currentOffset = currentOffset
            self.isTyped = isTyped
        }

        public func hasNext () throws -> Bool {
            return try structure.getSize() + 2 > currentOffset
        }

        @discardableResult
        public func next () throws -> XyoObjectStructure {

            let nextItem = try structure.readItemAtOffset(offset: currentOffset)

            if isTyped {
                currentOffset += try nextItem.getSize()
            } else {
                currentOffset += try nextItem.getSize() + 2
            }

            return nextItem
        }
    }

    public static func createTypedIterableObject (schema: XyoObjectSchema,
                                                  values: [XyoObjectStructure]) throws -> XyoIterableStructure {
        return XyoIterableStructure(value: try encodeTypedIterableObject(schema: schema, values: values))
    }

    public static func createUntypedIterableObject (schema: XyoObjectSchema,
                                                    values: [XyoObjectStructure]) -> XyoIterableStructure {
        return XyoIterableStructure(value: encodeUntypedIterableObject(schema: schema, values: values))
    }

    public static func encodeUntypedIterableObject (schema: XyoObjectSchema,
                                                    values: [XyoObjectStructure]) -> XyoBuffer {
        if schema.getIsTypedIterable() {
            fatalError("Schema is not untyped.")
        }

        let buffer = XyoBuffer()

        for item in values {
            buffer.put(buffer: item.getBuffer())
        }

        return XyoObjectStructure.encode(schema: schema, bytes: buffer)
    }

    static func encodeTypedIterableObject(schema: XyoObjectSchema, values: [XyoObjectStructure]) throws -> XyoBuffer {
        if !schema.getIsTypedIterable() {
            fatalError("Schema is not typed.")
        }

        if values.isEmpty {
            throw XyoObjectError.NOELEMENTS
        }

        let buffer = XyoBuffer()

        buffer.put(schema: try values[0].getSchema())

        for item in values {
            buffer.put(buffer: item.value.copyRangeOf(from: 2, toEnd: item.value.getSize()))
        }

        return XyoObjectStructure.encode(schema: schema, bytes: buffer)

    }

    public static func verify (item: XyoIterableStructure) throws {
        let iterator = try item.getNewIterator()

        while try iterator.hasNext() {
            let value = try iterator.next()

            if value is XyoIterableStructure {
                try verify(item: (value as! XyoIterableStructure))
            }
        }
    }

}
