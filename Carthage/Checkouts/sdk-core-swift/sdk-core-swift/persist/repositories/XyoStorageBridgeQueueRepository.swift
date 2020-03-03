//
//  XyoStorageBridgeQueueRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/26/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoStorageBridgeQueueRepository: XyoBridgeQueueRepository {
    
    
    private static let QUEUE_ARRAY_INDEX_KEY = Array("QUEUE_ARRAY_INDEX_KEY".utf8)
    private let store : XyoStorageProvider
    private var queueCache = [XyoBridgeQueueItem]()
    
    public init(storage : XyoStorageProvider) {
        self.store = storage
    }
    
    public func getQueue() -> [XyoBridgeQueueItem] {
        return queueCache
    }
    
    public func setQueue(queue: [XyoBridgeQueueItem]) {
        queueCache = queue
        saveQueue(items: queueCache)
    }
    
    public func addQueueItem(item: XyoBridgeQueueItem) {
        queueCache.insert(item, at: getInsertIndex(weight: item.weight))
        saveQueue(items: queueCache)
    }
    
    public func commit() {
        saveQueue(items: queueCache)
    }
    
    private func getInsertIndex (weight : Int) -> Int {
        if (queueCache.count == 0) {
            return 0
        }
        
        for i in 0...queueCache.count - 1 {
            if (queueCache[i].weight >= weight) {
                return i
            }
        }
        
        return 0
    }
    
    public func removeQueueItems(hashes: [XyoObjectStructure]) {
        for hash in hashes {
           removeItemFromQueueCache(hash: hash)
        }
    }
    
    public func incrementWeights(hashes: [XyoObjectStructure]) {
        for hash in hashes {
            let indexOfItem = (queueCache.firstIndex { (cachedItem) -> Bool in
                return cachedItem.hash.getBuffer().toByteArray() == hash.getBuffer().toByteArray()
            })
            
            if (indexOfItem != nil) {
                queueCache[indexOfItem!].weight += 1
            }
        }
    }
    
    
    public func getLowestWeight(n: Int) -> [XyoBridgeQueueItem] {
        if (queueCache.count == 0 || n == 0) {
            return []
        }
        
        var itemsToReturn = [XyoBridgeQueueItem]()
        
        for i in 0...min(n - 1, queueCache.count - 1) {
            itemsToReturn.append(queueCache[i])
        }
        
        return itemsToReturn
    }
    
    public func restoreQueue () {
        var items = [XyoBridgeQueueItem]()
        
        do {
            guard let encodedIndex = try store.read(key: XyoStorageBridgeQueueRepository.QUEUE_ARRAY_INDEX_KEY) else {
                return
            }
            
            let iterableIndex = try XyoIterableStructure(value: XyoBuffer(data: encodedIndex)).getNewIterator()
            
            while try iterableIndex.hasNext() {
                let structure = try iterableIndex.next() as? XyoIterableStructure
                
                if (structure != nil) {
                    let created = XyoBridgeQueueItem.fromStructure(structure: structure!)
                    
                    if (created != nil) {
                        items.append(created!)
                    }
                }
            }
            
            queueCache = items
        } catch {
            // handle this error
        }
    }
    
    private func saveQueue (items : [XyoBridgeQueueItem]) {
        var structures = [XyoObjectStructure]()
        
        for item in items {
            structures.append(item.toStructure())
        }
        
        do {
            let encodedIndex = try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.ARRAY_TYPED, values: structures).getBuffer().toByteArray()
            try store.write(key: XyoStorageBridgeQueueRepository.QUEUE_ARRAY_INDEX_KEY, value: encodedIndex)
        } catch {
            // todo handle this error
        }
    }
    
    private func removeItemFromQueueCache (hash: XyoObjectStructure) {
        guard let indexOfItem = (queueCache.firstIndex { (cachedItem) -> Bool in
            return cachedItem.hash.getBuffer().toByteArray() == hash.getBuffer().toByteArray()
        }) else { return }
        
        queueCache.remove(at: indexOfItem)
    }
}

extension XyoBridgeQueueItem {
    func toStructure () -> XyoObjectStructure {
        let weightStructure = XyoObjectStructure.newInstance(schema: XyoSchemas.BLOB, bytes: XyoBuffer().put(bits: UInt32(self.weight)))
        let hashStructre = self.hash
        
        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.ARRAY_UNTYPED, values: [hashStructre, weightStructure])
    }
    
    static func fromStructure (structure : XyoIterableStructure) -> XyoBridgeQueueItem? {
        do {
            let hash = try structure.get(index: 0)
            let weight = try structure.get(index: 1).getValueCopy().getUInt32(offset: 0)
            
            return XyoBridgeQueueItem(weight: Int(weight), hash: hash)
        } catch {
            return nil
        }
    }
}
