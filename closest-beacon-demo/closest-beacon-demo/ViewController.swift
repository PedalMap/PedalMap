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
    
    var beaconList = [Beacon]()
    
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
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        // NOTE: This assumes that closest beacon is first in the array. Not fit for production
        for x in knownBeacons {
            let beacon = Beacon()
            beacon.Major = x.major.integerValue
            beacon.Minor = x.minor.integerValue
            beacon.RSSI = x.rssi
         // TODO: loop through knownbeacons array and make sure that beacon doesn't already exist
            beaconList.append(beacon)
        // TODO: destroy beacons that don't exist
        }
        
        // print testing output for beacons
        
        print (region.proximityUUID);
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
        
        }
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
