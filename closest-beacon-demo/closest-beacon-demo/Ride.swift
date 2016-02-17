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

protocol RideEventDelegate: class {
    func updatedPolyLine(line: MKPolyline)
    func setRegion(region: MKCoordinateRegion, animated: Bool)
    func removePolyline()
    func updatedRideStats(speed: CLLocationSpeed, direction: CLLocationDirection, distance: CLLocationDistance, horizontalAccuracy: CLLocationAccuracy, avgSpeed: CLLocationSpeed)
}

class Ride: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var ridePoints: [RidePoint] = []
    let startTime = NSDate()
    private unowned var beacon: Beacon
    private unowned var rideEventDelegate: RideEventDelegate
    
    init(b: Beacon, red: RideEventDelegate) {
        beacon = b
        rideEventDelegate = red
        print ("Ride constructed for Beacon {\(beacon.Major), \(beacon.Minor)}")
    }
    
    deinit {
        print ("Ride deconstructed for Beacon {\(beacon.Major), \(beacon.Minor)}")
    }
    
    func startRide() {
        print ("Your ride has started!")
        rideEventDelegate.removePolyline()
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
    
    // returns average ride speed, which is sum of total ride speed points divided by total number ride points
    func avgSpeed(points: [RidePoint]) -> CLLocationSpeed {
        var rideSpeeds: [CLLocationSpeed] = []
        var avgSpeed: CLLocationSpeed
        
        // create an array of the ride's CLLocationSpeed points
        for x in points {
            rideSpeeds.append(x.speed)
        }
        
        // if ride speeds exist, sum them and divide by total number of ride speeds
        if (rideSpeeds.count > 0) {
            let speedSum = rideSpeeds.reduce(0, combine: +)
            avgSpeed = speedSum / Double(rideSpeeds.count)
        }
        else {avgSpeed = 0}
        return avgSpeed
    }
    
    func rideEvent() {
        let ridePointsCount = ridePoints.count
        var coords = getCoordinates(ridePoints)
        let myPolyline = MKPolyline(coordinates: &coords, count: ridePointsCount)
        rideEventDelegate.updatedPolyLine(myPolyline)
    }
    
    // update location of user based on location services
    
    func updateLocation() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
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
        
        // update map region
        let region = MKCoordinateRegion(center: latestCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        rideEventDelegate.setRegion(region, animated: true)
        
        // add new point to ridePoint array if horizontal accuracy < 65 meters and speed is non-negative number
        if horizontalAccuracy < 65 && speed >= 0 {
            self.ridePoints.append(RidePoint(l: latestLocation, c: latestCoordinate, a: altitude, h: horizontalAccuracy, v: verticalAccuracy, t: timestamp, s: speed, d: direction))
            rideEventDelegate.updatedRideStats(speed, direction: direction, distance: distanceTraveled(ridePoints), horizontalAccuracy: horizontalAccuracy, avgSpeed: avgSpeed(ridePoints))
            rideEvent()
        }
    }
}