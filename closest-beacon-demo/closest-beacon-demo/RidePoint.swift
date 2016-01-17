//
//  RidePoint.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 1/15/16.
//  Copyright © 2016 Zachary Browne. All rights reserved.
//

import Foundation
import MapKit

struct RidePoint {
    private var coordinate: CLLocationCoordinate2D
    private var altitude: CLLocationDistance
    private var horizontalAccuracy: CLLocationAccuracy
    private var verticalAccuracy: CLLocationAccuracy
    private var timestamp: NSDate
    
    init(c: CLLocationCoordinate2D, a: CLLocationDistance, h: CLLocationAccuracy, v: CLLocationAccuracy, t: NSDate) {
        coordinate = c
        altitude = a
        horizontalAccuracy = h
        verticalAccuracy = v
        timestamp = t
    }
}