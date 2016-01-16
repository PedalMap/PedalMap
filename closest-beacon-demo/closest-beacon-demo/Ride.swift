//
//  Ride.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 11/15/15.
//  Copyright © 2015 Zachary Browne. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Ride: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var latitude = String()
    var longitude = String()
    var rideCoordinates: [CLLocationCoordinate2D] = []    
    private unowned var beacon: Beacon
    private unowned var mapView: MKMapView
    
    init(b: Beacon, mv: MKMapView) {
        beacon = b
        mapView = mv
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

    // Need to figure out how to get this MKPolyline in the ViewController somehow
    func addRide() {
        let coordinateCount = rideCoordinates.count
        let myPolyline = MKPolyline(coordinates: &rideCoordinates, count: coordinateCount)
        mapView.addOverlay(myPolyline)
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
        let latestLocation = locations.last! as CLLocation
            latitude = String(format: "%.4f",
                latestLocation.coordinate.latitude)
            longitude = String(format: "%.4f",
                latestLocation.coordinate.longitude)
        let latestCoordinate = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        rideCoordinates.append(latestCoordinate)
        addRide()
        print (rideCoordinates)
    }
}