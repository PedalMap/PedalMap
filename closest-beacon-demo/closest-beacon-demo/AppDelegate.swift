//
//  AppDelegate.swift
//  closest-beacon-demo
//
//  Created by Zachary Browne on 2/7/15.
//  Copyright (c) 2015 Zachary Browne. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    private weak var ride: Ride?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSLog("app entered background")
        self.updateLocationForRanging()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("app did become active")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let _ = region as? CLBeaconRegion {
            let notification = UILocalNotification()
            notification.alertBody = "Welcome to the Pedalmap Region!"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let _ = region as? CLBeaconRegion {
            let notification = UILocalNotification()
            notification.alertBody = "You have left the Pedalmap Region :("
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    // customizable function for establishing location updates for both beacon ranging and ride states
    func startUpdatingLocation(delegate: CLLocationManagerDelegate, accuracy: CLLocationAccuracy) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.delegate = delegate
            locationManager.desiredAccuracy = accuracy
            locationManager.distanceFilter = 10.0
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = CLActivityType.Fitness
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
            locationManager.startUpdatingLocation()
        }
    }
    
    // call this function when a ride starts. Highest accuracy for good ride stats
    func updateLocationForRide(ride: Ride) {
        startUpdatingLocation(self, accuracy: kCLLocationAccuracyBestForNavigation)
        self.ride = ride
        NSLog("app ranging for a ride")
    }
    
    // call this function when a ride ends but we want to keep ranging. Weakest location accuracy to conserve battery while ranging
    func updateLocationForRanging() {
        if let _ = ride {
            self.ride = nil
        }
        startUpdatingLocation(self, accuracy: kCLLocationAccuracyThreeKilometers)
        NSLog("app ranging for background mode")
    }
    
    //  check to see if ride variable exists, if it does pass array information abck to ride
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let r = ride {
            r.getLocationInfo(locations)
            print ("updating location for a ride")
        }
        // add additional section for ranging info here
    }
}



