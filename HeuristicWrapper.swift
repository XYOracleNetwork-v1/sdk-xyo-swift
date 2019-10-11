//
//  HeuristicWrapper.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/10/19.
//

import Foundation
import sdk_objectmodel_swift
import sdk_core_swift
import CoreLocation

class HeuristicWrapper: XyoHeuristicGetter {
    let getter: SentinelHeuristicFetcher
    init(_getter: SentinelHeuristicFetcher) {
       getter = _getter
    }
    
    func getHeuristicData() -> XyoObjectStructure? {
        let heuristic : Data = getter.getHeuristic()
        return getBlobStructure(heuristic: heuristic)
    }
    
    func getHeuristicInt() -> XyoObjectStructure? {
        let heuristic : Int = getter.getHeuristic()
        return getBlobStructure(heuristic: heuristic)
    }
    
    func getHeuristicString() -> XyoObjectStructure? {
        let heuristic : String = getter.getHeuristic()
        return getBlobStructure(heuristic: heuristic)
    }
    
    func getBlobStructure(heuristic: Any) -> XyoIterableStructure {
        let encoded = XyoObjectStructure.newInstance(schema: XyoSchemas.BLOB, bytes: XyoBuffer(data: anyToBytes(heuristic)))
        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.BLOB, values: [encoded])
    }
    
    func getHeuristicLocation() -> XyoObjectStructure? {
        let heuristic : CLLocation = getter.getHeuristic()
        
        let encodedLat = XyoObjectStructure.newInstance(schema: XyoSchemas.LAT, bytes: XyoBuffer(data: anyToBytes(heuristic.coordinate.latitude)))
        let encodedLng = XyoObjectStructure.newInstance(schema: XyoSchemas.LNG, bytes: XyoBuffer(data: anyToBytes(heuristic.coordinate.longitude)))
        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.GPS, values: [encodedLat, encodedLng])
    }
    
    func getHeuristic () -> XyoObjectStructure? {
        let type = getter.getHeuristicType()
        switch type {
        case .data:
            return getHeuristicData()
        case .int:
            return getHeuristicInt()
        case .location:
            return getHeuristicLocation()
        case .string:
            return getHeuristicString()
        }
    }
    
    func anyToBytes<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }.reversed()
    }
}
