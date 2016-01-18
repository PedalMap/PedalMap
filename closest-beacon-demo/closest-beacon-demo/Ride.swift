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
    var rideCoordinates: [CLLocationCoordinate2D] = []
    var ridePoint: RidePoint?
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
        locationManager.stopUpdatingLocation()
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = false
        } else {
            // Fallback on earlier versions
        }
        print ("Your ride has ended :(")
    }
    
    func addRide() {
        let coordinateCount = rideCoordinates.count
        let myPolyline = MKPolyline(coordinates: &rideCoordinates, count: coordinateCount)
        mapView.addOverlay(myPolyline)
    }
    
    // update location of user based on location services
    
    func updateLocation() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 3
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = CLActivityType.Fitness
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
            locationManager.startUpdatingLocation()
            print ("updated location!")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations.last! as CLLocation
        let latitude = latestLocation.coordinate.latitude
        let longitude = latestLocation.coordinate.longitude
        let altitude = latestLocation.altitude
        let horizontalAccuracy = latestLocation.horizontalAccuracy
        let verticalAccuracy = latestLocation.verticalAccuracy
        let timestamp = latestLocation.timestamp
        let latestCoordinate = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        self.ridePoint = RidePoint(c: latestCoordinate, a: altitude, h: horizontalAccuracy, v: verticalAccuracy, t: timestamp)
        let region = MKCoordinateRegion(center: latestCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        rideCoordinates.append(latestCoordinate)
        addRide()
        //print (self.ridePoint!)
        print (rideCoordinates.count)
        print (latitude)
        print (longitude)
    }
}