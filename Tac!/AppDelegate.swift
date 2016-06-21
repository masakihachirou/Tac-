//
//  AppDelegate.swift
//  Tac!
//
//  Created by Andrew Fashion on 7/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit
import Parse
import Bolts
import GameKit

@UIApplicationMain 
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var gameFirstTime = true
    var quitRematchTimer: NSTimer?
    var inviteAccepted = false
    var versusComputer = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.setApplicationId("0MTxTJ1hzbc3UjvAfniFQBawvEjOXIdo7WzvZg50", clientKey: "XdHOkm2rjanKzzfBt7JU0P4669L21rEv5fERHHCz")
        
        
//        PFPurchase.addObserverForProduct("ThompsonAndExecutives.tacBundle1") { (transaction: SKPaymentTransaction?) -> Void in
//            addTacBundleToMyPurchases(tacBundle)
//        }
//        
//        PFPurchase.addObserverForProduct("ThompsonAndExecutives.tacBundle2") { (transaction: SKPaymentTransaction?) -> Void in
//            print("RESTORE PURCHASED TACBUNDLE2")
//        }
//        
//        PFPurchase.addObserverForProduct("ThompsonAndExecutives.tacBundle3") { (transaction: SKPaymentTransaction?) -> Void in
//            print("RESTORE PURCHASED TACBUNDLE3")
//        }
        
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        //UINavigationBar.appearance().tintColor = UIColor(rgba: "#4A4A4A")
        
        let customFont = UIFont(name: "Avenir", size: 14.0)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: customFont!], forState: UIControlState.Normal)
        
        
        
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor.lightGrayColor()
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        
        
        let dict = ["playerStatusChanged": "player left app"]
        var dictData: NSData?
        
        do {
            dictData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print(error)
        }
        
        do {
            try GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(dictData!, withDataMode: GKMatchSendDataMode.Reliable)
        } catch {
            print(error)
        }
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
        if gameFirstTime {
            gameFirstTime = false
        }
        else {
            if GameKitHelper.sharedInstance.multiplayerMatch?.players.count < 1 {
                GameKitHelper.sharedInstance.multiplayerMatch?.disconnect()
                if versusComputer == false {
                    NSNotificationCenter.defaultCenter().postNotificationName("goToMainMenu", object: nil)
                }
            }
            else {
                let dict = ["playerStatusChanged": "player came back to app"]
                let dictData: NSData?
                
                dictData = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)

                try! GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(dictData!, withDataMode: GKMatchSendDataMode.Reliable)
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

