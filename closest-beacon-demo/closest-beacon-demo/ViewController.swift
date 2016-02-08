//
//  ViewController.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 2/7/15.
//  Copyright (c) 2015 Zachary Browne. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, RideEventDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    // labels for data on the map
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
        
    let locationManager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID:
        NSUUID(UUIDString: "11231989-1989-1989-1989-112319891989")!, identifier: "Bicycle")
    var beaconDict = [Int: Beacon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // TODO: Add case for when user denies authorization
        locationManager.delegate = self;
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways) {
            locationManager.requestAlwaysAuthorization()
        }
        beaconRegion.notifyEntryStateOnDisplay = true
        startMonitoringRegion()
    }
    
    func startMonitoringRegion() {
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func stopMonitoringRegion() {
        locationManager.stopMonitoringForRegion(beaconRegion)
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Takes a dictionary of beacons and checks to see if a beacon with a given unique key matches a beacon in the dictionary
    func beaconInDict(dict: [Int: Beacon], major: Int, minor: Int) -> Beacon? {
        for (key, beacon) in dict {
            if (key == Beacon.key(major, minor: minor)) {
                return beacon
            }
        }
        return nil
    }

    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        // NOTE: This assumes that closest beacon is first in the array. Not fit for production
        // create a beacon object from each beacon in range and assign it a major, minor, and RSSI
        for x in knownBeacons {
            // if beeacon already exists in beaconDict, update RSSI, otherwise add it to the beaconDict
            if let beacon = beaconInDict(beaconDict, major: x.major.integerValue, minor: x.minor.integerValue) {
                beacon.update(x.rssi)
            } else {
                let beacon = Beacon(major: x.major.integerValue, minor: x.minor.integerValue, rssi: x.rssi, red: self)
                beaconDict[beacon.key()] = beacon
                print ("Beacon {\(beacon.Major), \(beacon.Minor)} added to beaconDict")
                print ("beaconDict contains " + String(beaconDict.count) + " beacons")
            }
        }
        // removes all beacons from the beaconDict that are in the beaconDict but not in range (part of knownBeacons array)
          for z in beaconDict {
            var found = false
            for y in knownBeacons {
                // When we find a beacon in range that matches a beacon in the dictionary, step out of loop iterating through beacons in range and move to next item in the dictionary
                if (z.1.compareToCLBeacon(y) == true) {
                    found = true
                    break // ends the inner loop when beacon nearby matches beacon in dictionary
                }
                // When a beacon in range doesn't match the beacon in dictionary, check the next beacon in range against same beacon in dictionary (increment inner loop)
                else {
                }
                // After we have checked all beacons in range (incremented through entire inner loop) but haven't found a match in range for the item in the dictionary, remove item in dictionary
            }
            if (!found) {
                z.1.outOfRange() // method that takes actions just before beacon is removed
                beaconDict[z.0] = nil // remove beacon from dictionary
            }
        }
    }
    
    // addes coordinates to mapview
    func updatedPolyLine(line: MKPolyline) {
        mapView.addOverlay(line)
    }
    
    // sets region for mapview
    func setRegion(region: MKCoordinateRegion, animated: Bool) {
        mapView.setRegion(region, animated: true)
    }
    
    // adds data to label fields on mapview
    func updatedRideStats(rideTime: NSDate, speed: CLLocationSpeed, direction: CLLocationDirection, distance: CLLocationDistance) {
        timeLabel.text = String(format: "%.4f", rideTime)
        speedLabel.text = String(format: "%.4f", speed)
        directionLabel.text = String(format: "%.4f", direction)
        distanceLabel.text = String(format: "%.4f", distance)
    }
    
    
}

// MARK: - Map View delegate

extension ViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
    let lineView = MKPolylineRenderer(overlay: overlay)
    lineView.strokeColor = UIColor.redColor()
    lineView.lineWidth = 3
        
    return lineView
    }
    return MKPolylineRenderer()
    }
}

