//
//  XyoPlayloadTestChecker.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift


func getFetterItem (boundWitness: XyoBoundWitness, itemId: UInt8, partyIndex: Int) -> XyoObjectStructure? {
    do {
        guard let fetter = try boundWitness.getFetterOfParty(partyIndex: partyIndex) else {
            return nil
        }
        
        let it = try fetter.getNewIterator()
        
        while try it.hasNext() {
            let item = try it.next()
            let schemaOfItem = try item.getSchema()
            
            if (schemaOfItem.id == itemId) {
                return item
            }
        }
        
    } catch {
        return nil
    }
    
    return nil
}

func getWitnessItem (boundWitness: XyoBoundWitness, itemId: UInt8, partyIndex: Int) -> XyoObjectStructure? {
    do {
        guard let witness = try boundWitness.getWitnessOfParty(partyIndex: partyIndex) else {
            return nil
        }
        
        let it = try witness.getNewIterator()
        
        while try it.hasNext() {
            let item = try it.next()
            let schemaOfItem = try item.getSchema()
            
            if (schemaOfItem.id == itemId) {
                return item
            }
        }
        
    } catch {
        return nil
    }
    
    return nil
}

func correctIndex (boundWitness: XyoBoundWitness, partyIndex: Int, indexNum: UInt32) -> Bool {
    do {
        guard let index = getFetterItem(boundWitness: boundWitness, itemId: XyoSchemas.INDEX.id, partyIndex: partyIndex) else {
            return false
        }
        
        let indexAsNum = try index.getValueCopy().getUInt32(offset: 0)
        return indexAsNum == indexNum
    } catch {
        return false
    }
}

//func correctPreviousHash () -> Bool {
//
//}
