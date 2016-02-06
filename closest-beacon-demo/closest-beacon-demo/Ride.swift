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
    var ridePoints: [RidePoint] = []
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
    
    // returns an array of CLLocationCoordinates for the ride that MKPolyline reads
    func getCoordinates(points: [RidePoint]) -> [CLLocationCoordinate2D] {
        var rideCoordinates: [CLLocationCoordinate2D] = []
        for x in points {
            rideCoordinates.append(x.coordinate)
        }
        return rideCoordinates
    }

    func distanceTraveled(points: [RidePoint]) -> CLLocationDistance {
        var distance = 0.0
        var rideLocations: [CLLocation] = []
        
        // create an array of the ride's CLLocations points
        for x in points {
            rideLocations.append(x.location)
        }
        
        // calculate distance between adjacent pairs of the ride's CLLocation points in the CLLocation array
        if rideLocations.count > 1 {
            for var index = 0; index < rideLocations.count - 1; ++index {
                distance += rideLocations[index].distanceFromLocation(rideLocations[index + 1])
            }
        }
        return distance
    }
    
    func addRide() {
        let ridePointsCount = ridePoints.count
        var coords = getCoordinates(ridePoints)
        let myPolyline = MKPolyline(coordinates: &coords, count: ridePointsCount)
        mapView.addOverlay(myPolyline)
        //print (ridePointsCount)
        //print (coords)
    }
    
    // update location of user based on location services
    
    func updateLocation() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 10.0
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
        let altitude = latestLocation.altitude
        let horizontalAccuracy = latestLocation.horizontalAccuracy
        let verticalAccuracy = latestLocation.verticalAccuracy
        let timestamp = latestLocation.timestamp
        let speed = latestLocation.speed
        let direction = latestLocation.course
        let latestCoordinate = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        // add new point to ridePoint array and mapview if horizontal accuracy < 100 meters (ideally lower this for production)
        if horizontalAccuracy < 100 {
            self.ridePoints.append(RidePoint(l: latestLocation, c: latestCoordinate, a: altitude, h: horizontalAccuracy, v: verticalAccuracy, t: timestamp, s: speed, d: direction))
        let region = MKCoordinateRegion(center: latestCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        addRide()
        print (distanceTraveled((ridePoints)))
        }
    }
}