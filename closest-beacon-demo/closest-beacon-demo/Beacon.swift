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

class Beacon : CustomStringConvertible {
    var description: String {
        return "Beacon {\(Major), \(Minor)}"
    }
    var Major = Int()
    var Minor = Int()
    var RSSI = Int()

    // creates unique key for identifying a beacon with a major/minor pair
    
    func key() -> Int {
        return Major << 16 + Minor // bitwise left shift operator
    }
    
    // function that updates beacons that already exist in our beacon dictionary
    func update(rssi: Int) {
        RSSI = rssi
    }
    
    // function to do something to beacons in our dictionary once we don't detect them in our range anymore
    func outOfRange() {
    }
    
    func compareToCLBeacon (beacon: CLBeacon) -> Bool {
        if (beacon.major.integerValue == Major && beacon.minor.integerValue == Minor) {
            return true
        }
        else {
            return false
        }
    }
}


    
    
    /* Do 3 things: Create, update, destroy

- Create when new UUID/major/minor is seen AND beacon not in list
- Update when UUID/major/minor exists AND beaacon is in list
- Destroy when UUID/major/minor IS NOT found BUT beacon is in list

method to update: during an update, report rssi. IF rssi is very close THEN create bicycle object
 - with this, we will determine when to start ride, how far to let RSSI drift while ride is still 
going, and when to cut off the ride


Model
- for as long as ViewController exists, it maintains list of beacons
- for as long as Beacon exists, it creates and destroys individual beacons within that list
*/
