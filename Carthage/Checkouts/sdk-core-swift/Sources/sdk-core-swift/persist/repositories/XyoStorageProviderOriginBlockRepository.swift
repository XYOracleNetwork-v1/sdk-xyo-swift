//
//  XyoStorageProviderOriginBlockRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoStorageProviderOriginBlockRepository: XyoOriginBlockRepository {
    
    private static let BLOCK_INDEX_KEY : [UInt8] = [0x00, 0x00]
    private let storageProvider : XyoStorageProvider
    private let hasher : XyoHasher
    
    public init(storageProvider : XyoStorageProvider, hasher : XyoHasher) {
        self.storageProvider = storageProvider
        self.hasher = hasher
    }
    
    public func removeOriginBlock (originBlockHash : [UInt8]) throws {
        try storageProvider.delete(key: originBlockHash)
        try updateIndex(hashToRemove: originBlockHash)
    }
    
    public func getOriginBlock (originBlockHash : [UInt8]) throws -> XyoBoundWitness? {
        guard let packedBlock = try storageProvider.read(key: originBlockHash) else {
            return nil
        }
        
        return XyoBoundWitness(value: XyoBuffer(data: packedBlock))
    }
    
    public func containsOriginBlock (originBlockHash : [UInt8]) throws -> Bool {
        return try storageProvider.containsKey(key: originBlockHash)
    }
    
    public func addOriginBlock (originBlock : XyoBoundWitness) throws {
        let hash = try originBlock.getHash(hasher: hasher)
        let key = hash.getBuffer().toByteArray()
        let value = originBlock.getBuffer().toByteArray()
        
        try storageProvider.write(key: key, value: value)
        try updateIndex(hashToAdd: hash)
    }
    
    private func getBlockIndex () throws -> XyoIterableStructure {
        guard let value = try storageProvider.read(key: XyoStorageProviderOriginBlockRepository.BLOCK_INDEX_KEY) else {
            return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.ARRAY_UNTYPED, values: [])
        }
        
        return XyoIterableStructure(value: XyoBuffer(data: value))
    }
    
    private func updateIndex (hashToAdd: XyoObjectStructure) throws {
        let currentIndex = try getBlockIndex()
        try currentIndex.addElement(element: hashToAdd)
        try storageProvider.write(
            key: XyoStorageProviderOriginBlockRepository.BLOCK_INDEX_KEY,
            value: currentIndex.getBuffer().toByteArray()
        )
    }
    
    private func updateIndex (hashToRemove: [UInt8]) throws {
        var newHashes = [XyoObjectStructure]()
        let currentIndex = try getBlockIndex().getNewIterator()
        
        while try currentIndex.hasNext() {
            let hashInList = try currentIndex.next()
            
            if (hashInList.getBuffer().toByteArray() != hashToRemove) {
                newHashes.append(hashInList)
            }
        }
        
        let newIndex = XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.ARRAY_UNTYPED, values: newHashes)
        try storageProvider.write(
            key: XyoStorageProviderOriginBlockRepository.BLOCK_INDEX_KEY,
            value: newIndex.getBuffer().toByteArray()
        )
    }
    
    public func getAllOriginBlockHashes () -> XyoIterableStructure {
        do {
            return try getBlockIndex()
        } catch {
            return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.ARRAY_UNTYPED, values: [])
        }
    }
}

