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
    var latitude = NSString()
    var longitude = NSString()
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
    }
    
    func endRide() {
        print (latitude)
        print (longitude)
        print ("Your ride has ended :(")
    }
    // update location of user based on location services
    
    func updateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print ("updated location!")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let latestLocation: AnyObject = locations[locations.count - 1]
            latitude = String(format: "%.4f",
                latestLocation.coordinate.latitude)
            longitude = String(format: "%.4f",
                latestLocation.coordinate.longitude)
        print (locations)
    }
}