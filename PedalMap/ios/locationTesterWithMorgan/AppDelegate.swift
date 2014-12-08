//
//  AppDelegate.swift
//  locationtesterapp
//
//  Created by Zachary Browne on 11/29/14.
//  Copyright (c) 2014 Zachary Browne. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    
    // Define a region to be monitored
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        let uuidString = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
        let beaconIdentifier = "iBeaconModules.us"
        let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)!
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
            identifier: beaconIdentifier)
            
        
        // Create CLLLocationManager instance and request "Always" authorization (new method in iOS 8)
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }

        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
            
        // Start monitoring the region, start ranging the beacons, and start updating location.
        // All three of these are required to receive range information updates when the app is in the background.
        locationManager!.startMonitoringForRegion(beaconRegion)
        locationManager!.startRangingBeaconsInRegion(beaconRegion)
        locationManager!.startUpdatingLocation()
        
        // Request permission from the user to send notifications (iOS 8 only, OS 7 ignores this). 
// TODO: handle the case where this is declined
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
                    categories: nil
                )
            )
        }
            
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
    
// Extension that sends local notifications based on a user's proximity to the nearest beacon
extension AppDelegate: CLLocationManagerDelegate {
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
            notification.alertBody = message
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    // Notify the user of the current status of the nearest beacon.
    func locationManager(manager: CLLocationManager!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
        // Pass the array of beacons to the View Controller and tell the table view to update itself
        let viewController:ViewController = window!.rootViewController as ViewController
            viewController.beacons = beacons as [CLBeacon]?
            viewController.tableView!.reloadData()
            
        NSLog("didRangeBeacons");
        var message:String = ""
            
        if(beacons.count > 0) {
            let nearestBeacon:CLBeacon = beacons[0] as CLBeacon
                
            // If the proximity hasn't changed or is temporarily unknown, the method returns and doesn't re-alert us.
            if(nearestBeacon.proximity == lastProximity ||
                nearestBeacon.proximity == CLProximity.Unknown) {
                    return;
            }
            lastProximity = nearestBeacon.proximity;
            switch nearestBeacon.proximity {
            case CLProximity.Far:
                message = "You are far away from the beacon"
            case CLProximity.Near:
                message = "You are near the beacon"
            case CLProximity.Immediate:
                message = "You are in the immediate proximity of the beacon"
            case CLProximity.Unknown:
                return
            }
        } else {
            message = "No beacons are nearby"
        }
    
        NSLog("%@", message)
        sendLocalNotificationWithMessage(message)
    }

    // Logs and alerts us of the system-level region entry/exit.
    func locationManager(manager: CLLocationManager!,
        didEnterRegion region: CLRegion!) {
            manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
            manager.startUpdatingLocation()
            
            NSLog("You entered the region")
            sendLocalNotificationWithMessage("You entered the region")
    }
    
    func locationManager(manager: CLLocationManager!,
        didExitRegion region: CLRegion!) {
            manager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
            manager.stopUpdatingLocation()
            
            NSLog("You exited the region")
            sendLocalNotificationWithMessage("You exited the region")
    }
}

