//
//  XyoBoundWitnessUtil.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/23/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoBoundWitnessUtil {
    
    public static func removeIdFromUnsignedPayload (id: UInt8, boundWitness : XyoIterableStructure) throws -> XyoBoundWitness {
        var newBoundWitnessLedger : [XyoObjectStructure] = []
        
        let fetters = try boundWitness.get(objectId: XyoSchemas.FETTER.id)
        let witnesses = try boundWitness.get(objectId: XyoSchemas.WITNESS.id)
        
        newBoundWitnessLedger.append(contentsOf: fetters)
        
        for witness in witnesses {
            newBoundWitnessLedger.append(try removeTypeFromWitness(witness: witness, id: id))
        }
        
        let createBoundWitness = XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.BW, values: newBoundWitnessLedger).getBuffer()
        return XyoBoundWitness(value: createBoundWitness)
    }
    
    private static func removeTypeFromWitness (witness : XyoObjectStructure, id: UInt8) throws -> XyoIterableStructure {
        var newWitnessContents : [XyoObjectStructure] = []
        
        guard let typedWitness = witness as? XyoIterableStructure else {
            throw XyoObjectError.NOTITERABLE
        }
        
        let it = try typedWitness.getNewIterator()
        
        while try it.hasNext() {
            let item = try it.next()
            
            if try item.getSchema().id != id {
                newWitnessContents.append(item)
            }
        }
        
        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.WITNESS, values: newWitnessContents)
    }
    
    public static func getPartyNumberFromPublicKey (publickey : XyoObjectStructure, boundWitness : XyoBoundWitness) throws -> Int? {
        for i in 0...(try boundWitness.getNumberOfParties() ?? 0) {
            
            guard let fetter = try boundWitness.getFetterOfParty(partyIndex: i) else {
                return nil
            }
            
            if (try checkPartyForPublicKey(fetter: fetter, publicKey: publickey)) {
                return i
            }
        }
        
        return nil
    }
    
    private static func checkPartyForPublicKey (fetter : XyoIterableStructure, publicKey : XyoObjectStructure) throws -> Bool {
        for keySet in (try fetter.get(objectId: XyoSchemas.KEY_SET.id)) {
            guard let typedKeyset = keySet as? XyoIterableStructure else {
                return false
            }
            
            if ((try checkKeySetForPublicKey(keyset: typedKeyset, publicKey: publicKey))) {
                return true
            }
            
        }
        
        return false
    }
    
    private static func checkKeySetForPublicKey (keyset : XyoIterableStructure, publicKey : XyoObjectStructure) throws -> Bool {
        
        let it = try keyset.getNewIterator()
        
        while try it.hasNext() {
            if try it.next().getBuffer().toByteArray() == publicKey.getBuffer().toByteArray() {
                return true
            }
        }
        
        return false
    }
}
