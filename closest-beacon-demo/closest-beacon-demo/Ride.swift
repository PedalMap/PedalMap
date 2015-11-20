//
//  Ride.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 11/15/15.
//  Copyright © 2015 Zachary Browne. All rights reserved.
//

import Foundation

class Ride {
    
    init() {
        print ("Ride constructed")
    }
    
    deinit {
        print ("Ride deconstructed")
    }
    
    func startRide() {
        print ("Your ride has started!")
    }
    
    func endRide() {
        print ("Your ride has ended :(")
    }
    
}