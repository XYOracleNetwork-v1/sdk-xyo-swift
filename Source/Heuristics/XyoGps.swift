//
//  XyoGps.swift
//  XYO
//
//  Created by Carter Harrison on 3/26/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift
import sdk_objectmodel_swift
import CoreLocation

public struct XyoGps: XyoHueresticGetter {
    let locManager = CLLocationManager()

    init() {
        locManager.requestWhenInUseAuthorization()
        locManager.distanceFilter = kCLDistanceFilterNone
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locManager.startUpdatingLocation()
    }

    public func getHeuristic() -> XyoObjectStructure? {
        guard let lat: Double = locManager.location?.coordinate.latitude else {
            return nil
        }

        guard let lng: Double = locManager.location?.coordinate.longitude else {
            return nil
        }

        let encodedLat = XyoObjectStructure.newInstance(schema: XyoSchemas.LAT, bytes: XyoBuffer(data: anyToBytes(lat)))
        let encodedLng = XyoObjectStructure.newInstance(schema: XyoSchemas.LNG, bytes: XyoBuffer(data: anyToBytes(lng)))

        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.GPS, values: [encodedLat, encodedLng])
    }

    public func anyToBytes<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }.reversed()
    }
}
