//
//  Ride.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 11/15/15.
//  Copyright © 2015 Zachary Browne. All rights reserved.
//

import Foundation
import CoreLocation

class Ride: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var LatitudeGPS = NSString()
    var LongitudeGPS = NSString()
    private unowned var beacon: Beacon
    
    init(b: Beacon) {
        beacon = b
        print ("Ride constructed for Beacon {\(beacon.Major), \(beacon.Minor)}")
    }
    
    deinit {
        print ("Ride deconstructed for Beacon {\(beacon.Major), \(beacon.Minor)}")
    }
    
    func startRide() {
        print ("Your ride has started!")
        updateLocation()
        print (LatitudeGPS)
        print (LongitudeGPS)
    }
    
    func endRide() {
        print ("Your ride has ended :(")
    }
    // update location of user based on location services
    
    func updateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func setLatLong(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LatitudeGPS = String(format: "%.6f", manager.location!.coordinate.latitude)
        LongitudeGPS = String(format: "%.6f", manager.location!.coordinate.longitude)
    }
    
}