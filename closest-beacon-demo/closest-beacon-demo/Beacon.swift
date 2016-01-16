//
//  Beacon.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 10/18/15.
//  Copyright © 2015 Zachary Browne. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class Beacon : CustomStringConvertible {
    var description: String {
        return "Beacon {\(Major), \(Minor)}"
    }
    var Major = Int()
    var Minor = Int()
    var RSSI = Int()
    
    var ride: Ride?
    
    private unowned var mapView: MKMapView

    init(major: Int, minor: Int, rssi: Int, mv: MKMapView) {
        Major = major
        Minor = minor
        RSSI = Int.min
        mapView = mv
        print ("Created beacon: \(self)")
        update(rssi)
    }
    
    // creates unique key for identifying a beacon with a major/minor pair
    
    func key() -> Int {
        return Beacon.key(Major, minor: Minor)
    }
    
    static func key(major: Int, minor: Int) -> Int {
        return major << 16 + minor // bitwise left shift operator
    }
    
    // function that updates beacons that already exist in our beacon dictionary
    func update(rssi: Int) {
        if (rssi == RSSI) { return }
        RSSI = rssi
        
        if (ride == nil) {
            if (RSSI > -50) {
                self.ride = Ride(b: self, mv: mapView)
                self.ride!.startRide()
            }
        } else {
            if (RSSI < -80) {
                self.ride!.endRide()
                self.ride = nil
            }
        }
    }
    
    deinit {
        print ("Destroying beacon: \(self)")
    }
    
    // function to do something to beacons in our dictionary once we don't detect them in our range anymore
    func outOfRange() {
        update(Int.min) // ends our ride by running through the update function before we remove the beacon from the dictionary
        print ("Beacon {\(Major), \(Minor)} removed from beaconDict")
    }
    
    // function that checks to see if a beacon object is in range
    func compareToCLBeacon (beacon: CLBeacon) -> Bool {
        if (beacon.major.integerValue == Major && beacon.minor.integerValue == Minor) {
            return true
        }
        else {
            return false
        }
    }
}
