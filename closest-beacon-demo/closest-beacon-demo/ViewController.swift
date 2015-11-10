//
//  ViewController.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 2/7/15.
//  Copyright (c) 2015 Zachary Browne. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var LatitudeGPS = NSString()
    var LongitudeGPS = NSString()
    let region = CLBeaconRegion(proximityUUID:
        NSUUID(UUIDString: "11231989-1989-1989-1989-112319891989")!, identifier: "Bicycle")
    var beaconDict = [Int: Beacon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // TODO: Add case for when user denies authorization
        locationManager.delegate = self;
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        updateLocation()
        locationManager.startRangingBeaconsInRegion(region)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Takes a dictionary of beacons and checks to see if a beacon with a given unique key matches a beacon in the dictionary
    func isBeaconInDict(dict: [Int: Beacon], beacon: Beacon) -> Beacon? {
        for (key, value) in dict {
            if (key == beacon.key()) {
                return value
            }
        }
        return nil
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        // NOTE: This assumes that closest beacon is first in the array. Not fit for production
        for x in knownBeacons {
            let beacon = Beacon()
            beacon.Major = x.major.integerValue
            beacon.Minor = x.minor.integerValue
            beacon.RSSI = x.rssi
            let inDict = isBeaconInDict(beaconDict, beacon: beacon)
            if (inDict != nil)  {
                beacon.update(x.rssi)
            } else {
                beaconDict[beacon.key()] = beacon
            }
            print (beaconDict)
            print (beacon.Major)
            print (beacon.Minor)
            print (beacon.RSSI)
        }
        
        /* TODO: destroy beacons that don't exist. To destroy a beacon, we do two things
        1) call the outOfRange function
        2) remove the beacon from the beacon dictionary
        in order to do this, we need to loop through the dictionary and look for beacons that exist in the dictionary but NOT in the range...then we kindly address them with the outOfRange() function and then we destroy!!! To do this, we need nested loop. Inner loop will run through all of the knownBeacons and check them against a dictionary item, the outside loop will increment the dictionary down one and check for the next dictionary item. */
        
        for z in knownBeacons {
            for y in beaconDict {
                if (y.1.compareToCLBeacon(z) == false) {
                    y.1.outOfRange()
                    beaconDict[y.0] = nil // remove beacon from dictionary
                }
                else {
                    return
                }
            }
        }
        
        // print testing output for beacons
        
        /*print (region.proximityUUID);
        print (region.identifier);
        print (knownBeacons);
        print (knownBeacons.count);
        for beacon in knownBeacons{
            print(beacon.proximity.rawValue);
            if (beacon.proximity.rawValue == 1) {
                print(LatitudeGPS);
                print(LongitudeGPS)
            }
        print(beacon.accuracy);
        print (CLLocationManager.locationServicesEnabled());
        print (beacon.rssi);
        
        }*/
    }
    
    // update location of user based on location services
    
    func updateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // print user lat long
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LatitudeGPS = String(format: "%.6f", manager.location!.coordinate.latitude)
        LongitudeGPS = String(format: "%.6f", manager.location!.coordinate.longitude)
    }
}
