//
//  XyoBoundWitness.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

open class XyoBoundWitness : XyoIterableStructure {
    
    public func getIsCompleted () throws -> Bool {
        if try self.get(id: XyoSchemas.WITNESS.id).count > 0 {
            return try self.get(id: XyoSchemas.FETTER.id).count == (try self.get(id: XyoSchemas.WITNESS.id).count)
        }
        
        return false
    }
    
    public func getNumberOfFetters () throws -> Int {
        return try self.get(id: XyoSchemas.FETTER.id).count
    }
    
    public func getNumberOfWitnesses () throws -> Int {
        return try self.get(id: XyoSchemas.WITNESS.id).count
    }
    
    public func getHash (hasher : XyoHasher) throws -> XyoObjectStructure {
        return try hasher.hash(data: getSigningData())
    }
    
    public func signCurrent (signer : XyoSigner) throws -> XyoObjectStructure {
        
        return try signer.sign(data: getSigningData())
    }
    
    public func addToLedger (item : XyoObjectStructure) throws {
        if try getIsCompleted() {
            throw XyoError.BW_IS_COMPLETED
        }
        
        try addElement(element: item)
    }
    
    internal func getSigningData () throws -> [UInt8] {
        return try getValueCopy().copyRangeOf(from: 0, toEnd: getWitnessFetterBoundry()).toByteArray()
    }
    
    public func getNumberOfParties () throws -> Int? {
        let numberOfFetters = try self.get(id: XyoSchemas.FETTER.id).count
        let numberOfWitness = try self.get(id: XyoSchemas.WITNESS.id).count
        
        if (numberOfFetters == numberOfWitness) {
            return numberOfFetters
        }
        
        return nil
    }
    
    public func getFetterOfParty (partyIndex : Int) throws -> XyoIterableStructure? {
        guard let numberOfParties = try getNumberOfParties() else {
            return nil
        }
        
        if numberOfParties <= partyIndex {
            return nil
        }
        
        
        return try self.get(index: partyIndex) as? XyoIterableStructure
    }
    
    public func getWitnessOfParty (partyIndex : Int) throws -> XyoIterableStructure? {
        guard let numberOfParties = try getNumberOfParties() else {
            return nil
        }
        
        if numberOfParties <= partyIndex {
            return nil
        }
        
        
        return try self.get(index: (numberOfParties * 2) - (partyIndex + 1)) as? XyoIterableStructure
    }
    
    private func getWitnessFetterBoundry () throws -> Int {
        let fetters = try self.get(id: XyoSchemas.FETTER.id)
        var offsetIndex = 0
        
        for fetter in fetters {
            offsetIndex += try fetter.getSize() + 2
        }
        
        return offsetIndex
    }
    

    static func createMasterArrayWithSubArray (masterSchema : XyoObjectSchema,
                                               subSchema : XyoObjectSchema,
                                               masterItems: [XyoObjectStructure],
                                               subItems: [XyoObjectStructure]) -> XyoObjectStructure {
        let sub = XyoIterableStructure.createUntypedIterableObject(schema: subSchema, values: subItems)
        var itemsInMaster : [XyoObjectStructure] = [sub]
        itemsInMaster.append(contentsOf: masterItems)
        return XyoIterableStructure.createUntypedIterableObject(schema: masterSchema, values: itemsInMaster)
    }
}
