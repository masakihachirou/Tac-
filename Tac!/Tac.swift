//
//  Tac.swift
//  Tac!
//
//  Created by Andrew Fashion on 8/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit
import Parse

class Tac: NSObject {
    
    var tacSet = [String]()
    var bundleName: String?
    var bundleID: Int?
    
    let fileManager = NSFileManager.defaultManager()
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
    var defaults = NSUserDefaults.standardUserDefaults()
    
    func getAllTacsFromParseDatabase(completionHandler:(succes: Bool, tacSets: [Tac]) -> ())
    {
        let query = PFQuery(className: "Tacs")
        query.addAscendingOrder("name")
        query.cachePolicy = PFCachePolicy.NetworkElseCache
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil
            {
                if let objects = objects as? [PFObject] {
                    var tacs = [Tac]()
                    var counter = 0
                    
                    for object in objects {
                        let tac = Tac()
                        
                        let parseBundleName = object.objectForKey("name") as? String
                        tac.bundleName = "\(parseBundleName!)"
                        tac.bundleID = object.objectForKey("bundleID") as? Int
                        
                        self.getPurchasedTacs({ (success, tacSets) -> () in
                            
                            if let index = tacSets.indexOf("\(tac.bundleName!)-set1") {
                                print("you own this one already")
                                counter++
                            } else {
                                counter++
                                tacs.append(tac)
                            }
                        
                        })
                    }
                    
                    if counter == objects.count {
                        completionHandler(succes: true, tacSets: tacs)
                    }
                }
            }
        }
    }
    
    func installFreeTacPieces() {
        
        //defaults.removeObjectForKey("purchasedTacs")
        
        let set1 = "tacBundle0-set1"
        let set2 = "tacBundle0-set2"
        let set3 = "tacBundle0-set3"
        
        if let purchasedTacs = defaults.objectForKey("purchasedTacs") as? [String] {
            
            if let index = purchasedTacs.indexOf(set1) {

                print("FREE SETS ALREADY INSTALLED")
                print(purchasedTacs)
                
            } else {
                
                var purchasedTacBundles = purchasedTacs
                
                purchasedTacBundles.append(set1)
                purchasedTacBundles.append(set2)
                purchasedTacBundles.append(set3)
                
                defaults.setObject(purchasedTacBundles, forKey: "purchasedTacs")
                
                print(purchasedTacBundles)
                
            }
            
        } else {
            
            let purchasedTacBundles = [set1, set2, set3]
            self.defaults.setObject(purchasedTacBundles, forKey: "purchasedTacs")
            
            print(purchasedTacBundles)
            
        }
        
    }
    
    func downloadAllTacSets(completionHandler:(success: Bool) -> ()) {
        let query = PFQuery(className: "Tacs")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {

                var resolution = "2x"
                
                if UIScreen.mainScreen().scale == 1.0 {
                    resolution = "1x"
                    print("downloading 1x")
                } else if UIScreen.mainScreen().scale == 2.0 {
                    resolution = "2x"
                    print("downloading 2x")
                } else {
                    resolution = "3x"
                    print("downloading 3x")
                }
                
                
                print(self.paths)
                
                
                
                
                if let objects = objects as? [PFObject] {
                    
                    var counter = 0
                    print("start counter \(counter)")
                    print("objects count \(objects.count)")
                    
                    for object in objects {
                        
                        let tacBundle = object.objectForKey("name") as! String
                        let tacImage = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("tacX-\(tacBundle)-set1.png")
                        
                        if (self.fileManager.fileExistsAtPath(tacImage.path!)) {
                            
                            counter++
                        
                        } else {
                            
                            //var set1 = "\(tacBundle)-set1"
                            //var set2 = "\(tacBundle)-set2"
                            
                            if let x = object.objectForKey("tacX_\(resolution)") as? PFFile {
                                x.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                                    if error == nil {
                                        if let data = data {
                                            let filePathToWrite = "\(self.paths)/tacX-\(tacBundle)-set1.png"
                                            self.fileManager.createFileAtPath(filePathToWrite, contents: data, attributes: nil)
                                        }
                                    }
                                })
                            }
                            
                            if let o = object.objectForKey("tacO_\(resolution)") as? PFFile {
                                o.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                                    if error == nil {
                                        if let data = data {
                                            let filePathToWrite = "\(self.paths)/tacO-\(tacBundle)-set1.png"
                                            self.fileManager.createFileAtPath(filePathToWrite, contents: data, attributes: nil)
                                        }
                                    }
                                })
                            }
                            
                            if let x2 = object.objectForKey("tacX2_\(resolution)") as? PFFile {
                                x2.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                                    if error == nil {
                                        if let data = data {
                                            let filePathToWrite = "\(self.paths)/tacX-\(tacBundle)-set2.png"
                                            self.fileManager.createFileAtPath(filePathToWrite, contents: data, attributes: nil)
                                        }
                                    }
                                })
                            }
                            
                            if let o2 = object.objectForKey("tacO2_\(resolution)") as? PFFile {
                                o2.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                                    if error == nil {
                                        if let data = data {
                                            let filePathToWrite = "\(self.paths)/tacO-\(tacBundle)-set2.png"
                                            self.fileManager.createFileAtPath(filePathToWrite, contents: data, attributes: nil)
                                            counter++
                                        }
                                    }
                                })
                            }
                            
                            print("incrementing counter: \(counter)")
                            
                        }
                        
                        if counter == objects.count {
                            
                            print("counter = objects")
                            completionHandler(success: true)
                            
                        }
                    
                    }
                }
                    
            }
            
        }
    }
    
    func buyTacBundle(tacBundle: String, completionHandler:(success: Bool) -> ()) {
        PFPurchase.buyProduct("ThompsonAndExecutives.\(tacBundle)") { (error: NSError?) -> Void in
            if error != nil {
                
                print(error?.localizedDescription)
                print("failed buying")
                
            } else {
                
                self.addTacBundleToMyPurchases(tacBundle)
                print("success buying")
                completionHandler(success: true)
                
            }
        }
    }
    
    func getPurchasedTacs(completionHandler:(success: Bool, tacSets: [String]) -> ()) {
        
        if let purchasedTacs = defaults.objectForKey("purchasedTacs") as? [String] {
            completionHandler(success: true, tacSets: purchasedTacs)
        }
        
    }
    
    func addTacBundleToMyPurchases(tacBundle: String) {
        
        let set1 = "\(tacBundle)-set1"
        let set2 = "\(tacBundle)-set2"
        
        if let purchasedTacs = defaults.objectForKey("purchasedTacs") as? [String] {
            
            if let index = purchasedTacs.indexOf(set1) {
                
                print("you already own this set")
                print(purchasedTacs)
                
            } else {
            
                var purchasedTacBundles = purchasedTacs
                
                purchasedTacBundles.append(set1)
                purchasedTacBundles.append(set2)
                
                defaults.setObject(purchasedTacBundles, forKey: "purchasedTacs")
                
                print(purchasedTacBundles)
                
            }
        
        } else {

            let purchasedTacBundles = [set1, set2]
            self.defaults.setObject(purchasedTacBundles, forKey: "purchasedTacs")
            
            print(purchasedTacBundles)
            
        }
    }
    
    
    
    
}
