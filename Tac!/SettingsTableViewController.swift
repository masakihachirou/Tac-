//
//  SettingsTableViewController.swift
//  Tac!
//
//  Created by Andrew Fashion on 8/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit
import Parse

class SettingsTableViewController: UITableViewController, PurchaseCellDelegate, MyTacsDelegate, SKPaymentTransactionObserver {
    
    var tac = Tac()
    var tacSets = [Tac]()
    var purchasedTacSets = [String]()
    var tacLinks = [[String]]()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // WHERE TO SAVE IMAGES
    let fileManager = NSFileManager.defaultManager()
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    var fingerIndexPath: NSIndexPath?
    var didTapHappen: Bool = false
    var fingerAlreadyOut: Bool = false
    var fingerAlreadyOutIndexPath: NSIndexPath?
    
    var lockerView: UIView?
    var tacLoaderView: LoaderView?
    let loadingView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: nil, options: nil)[0] as! LoadingScreen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lockerView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        tacLoaderView = LoaderView(frame: CGRectMake(0, -100, 100, 100))
        lockerView!.backgroundColor = UIColor.clearColor()
        lockerView!.alpha = 0
        view.addSubview(lockerView!)
        lockerView!.addSubview(tacLoaderView!)
        tacLoaderView!.center = view.center
        
        loadingView.alpha = 0
        loadingView.backToMenuButton.hidden = true
        loadingView.topText.text = "購入の復元"
        loadingView.subTitleText.text = "Wait for recovery"
        loadingView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
        self.view.addSubview(loadingView)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "customBack"), style: UIBarButtonItemStyle.Plain, target: self, action: "goBackButton")
        
        PFPurchase.addObserverForProduct("ThompsonAndExecutives.tacBundle1") { (transaction: SKPaymentTransaction?) -> Void in
            self.tac.addTacBundleToMyPurchases("tacBundle1")
        }
        
        PFPurchase.addObserverForProduct("ThompsonAndExecutives.tacBundle2") { (transaction: SKPaymentTransaction?) -> Void in
            self.tac.addTacBundleToMyPurchases("tacBundle2")
        }
        
        PFPurchase.addObserverForProduct("ThompsonAndExecutives.tacBundle3") { (transaction: SKPaymentTransaction?) -> Void in
            self.tac.addTacBundleToMyPurchases("tacBundle3")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "buyTacSet", name: "BuyTacSet", object: nil)
        
        tableView.registerNib(UINib(nibName: "MyTacsHeaderCell", bundle: nil), forCellReuseIdentifier: "MyTacsHeaderCell")
        tableView.registerNib(UINib(nibName: "MyTacsCell", bundle: nil), forCellReuseIdentifier: "MyTacsCell")
        
        tableView.registerNib(UINib(nibName: "PurchaseTacsHeaderCell", bundle: nil), forCellReuseIdentifier: "PurchaseTacsHeaderCell")
        tableView.registerNib(UINib(nibName: "PurchaseTacsCell", bundle: nil), forCellReuseIdentifier: "PurchaseTacsCell")
        
        tableView.registerNib(UINib(nibName: "FooterCell", bundle: nil), forCellReuseIdentifier: "FooterCell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        navigationController?.navigationBar.backItem?.title = "Settings"
        
        //startCustomLoader(self.view)
        
        tac.getPurchasedTacs { (success, tacSets) -> () in
            
            startLoader("Loading...", view: self.view)
            
            if success == true {
                
                // THESE ARE FREE TAC BUNDLES
                self.purchasedTacSets = tacSets
                print(tacSets)
                self.tac.getAllTacsFromParseDatabase { (success, tacSets) -> () in
                    if success == true {
                        
                        // THESE ARE FOR SALE TAC BUNDLES
                        self.tacSets = tacSets
                        self.tableView.reloadData()
                        stopLoader(self.view)
                    }
                }
            }
        }
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBarHidden = true
    }
    
    func goBackButton() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // MyTacsHeaderCell
        if section == 0 {
            return 1
            
            // MyTacs
        } else if section == 1 {
            return purchasedTacSets.count
            
            // PurchaseTacsHeaderCell
        } else if section == 2 {
            return 1
            
            // PurchaseTacsHeader
        } else if section == 3 {
            return tacSets.count
            
            // FooterCell
        } else if section == 4 {
            return 1
            
        } else {
            return 1
        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyTacsHeaderCell", forIndexPath: indexPath) as! MyTacsHeaderCell
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyTacsCell", forIndexPath: indexPath) as! MyTacsCell
            
            
            
            cell.fingerImageView.alpha = 0
            
            let tacBundle = purchasedTacSets[indexPath.row]
            
            if let customSet = NSUserDefaults.standardUserDefaults().objectForKey("customSet") as? String {
                print("CustomSET: \(customSet)    TacBundle: \(tacBundle)")
                
                if customSet == tacBundle {
                    cell.fingerImageView.alpha = 1
                    fingerAlreadyOut = true
                    fingerIndexPath = indexPath
                }
                
            } else {
                
            }
            
            if tacBundle == "tacBundle0-set1" {
                
                cell.xImageView.image = UIImage(named: "tacX-\(tacBundle)")
                cell.oImageView.image = UIImage(named: "tacO-\(tacBundle)")
                cell.setName = "\(tacBundle)"
                
            } else if tacBundle == "tacBundle0-set2" {
                
                cell.xImageView.image = UIImage(named: "tacX-\(tacBundle)")
                cell.oImageView.image = UIImage(named: "tacO-\(tacBundle)")
                
                cell.setName = "\(tacBundle)"
                
            } else if tacBundle == "tacBundle0-set3" {
                
                cell.xImageView.image = UIImage(named: "tacX-\(tacBundle)")
                cell.oImageView.image = UIImage(named: "tacO-\(tacBundle)")
                
                cell.setName = "\(tacBundle)"
                
            } else {
                
                //var xPath = self.paths.stringByAppendingPathComponent("tacX-\(tacBundle).png")
                //var oPath = self.paths.stringByAppendingPathComponent("tacO-\(tacBundle).png")
                
                
                
                let xPath = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("tacX-\(tacBundle).png")
                let oPath = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("tacO-\(tacBundle).png")
                
                
                //cell.xImageView.setImage(UIImage(contentsOfFile: xPath))
                //cell.oImageView.setImage(UIImage(contentsOfFile: oPath))
                
                // TODO: SET THESE IMAGES MOTHER FUCKER
                
                cell.xImageView.image = UIImage(data: NSData(contentsOfURL: xPath)!)
                cell.oImageView.image = UIImage(data: NSData(contentsOfURL: oPath)!)
                
                cell.setName = "\(tacBundle)"
                
            }
            
            cell.delegate = self
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PurchaseTacsHeaderCell", forIndexPath: indexPath) as! PurchaseTacsHeaderCell
            return cell
            
            
        } else if indexPath.section == 3 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PurchaseTacsCell", forIndexPath: indexPath) as! PurchaseTacsCell
            
            let tac = tacSets[indexPath.row]
            
            print("\(tac.bundleName!) -- \(indexPath.row)")
            
            let tacX = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("tacX-\(tac.bundleName!)-set1.png")
            let tacO = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("tacO-\(tac.bundleName!)-set1.png")
            let tacX2 = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("tacX-\(tac.bundleName!)-set2.png")
            let tacO2 = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("tacO-\(tac.bundleName!)-set2.png")
            
            cell.pieceOne.image = UIImage(data: NSData(contentsOfURL: tacX)!)
            cell.pieceTwo.image = UIImage(data: NSData(contentsOfURL: tacO)!)
            cell.pieceThree.image = UIImage(data: NSData(contentsOfURL: tacX2)!)
            cell.pieceFour.image = UIImage(data: NSData(contentsOfURL: tacO2)!)
            
            cell.delegate = self
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FooterCell", forIndexPath: indexPath) as! FooterCell
            return cell
            
        }
        
    }
    
    func purchaseButtonTapped(cell: PurchaseTacsCell) {
        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
        let tac = tacSets[indexPath.row]
        
        print("ThompsonAndExecutives.tacBundle\(tac.bundleID!)")
        
        tac.buyTacBundle("tacBundle\(tac.bundleID!)", completionHandler: { (success) -> () in
            
            if success == true {
                
                self.tac.getPurchasedTacs { (success, tacSets) -> () in
                    if success == true {
                        
                        // MY TAC SETS AT THE THE TOP!
                        self.purchasedTacSets = tacSets
                        
                        self.tac.getAllTacsFromParseDatabase({ (succes, tacSets) -> () in
                            self.tacSets = tacSets
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                            self.tableView.scrollsToTop = true
                            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
                            
                        })
                        
                        self.tableView.reloadData()
                        
                    }
                }
            }
        })
        
    }
    
    // MARK: MY TACS
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! MyTacsCell
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                cell.fingerImageView.alpha = 0
            })
            
            cell.fingerImageView.animation = "slideRight"
            cell.fingerImageView.duration = 1
            cell.fingerImageView.animate()
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                
            })
            
            // SET AS NEW SET
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(cell.setName, forKey: "customSet")
            print(cell.setName)
            
        }
        
        if indexPath.section == 3 {
            
        }
        
        if indexPath.section == 4 {
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.loadingView.alpha = 1
            })
            
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
            
            
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // MyTacsHeaderCell
        if indexPath.section == 0 {
            return 55
            
            // MyTacsCell
        } else if indexPath.section == 1 {
            return 120
            
            // PurchaseTacsHeaderCell
        } else if indexPath.section == 2 {
            if tacSets.count == 0 {
                return 0
            } else {
                return 100
            }
            
            // PurchaseTacsCell
        } else if indexPath.section == 3 {
            return 365
            
            // FooterCell
        } else if indexPath.section == 4 {
            return 100
            
        } else {
            return 1
        }
    }
    
    
    func didTapFingerCell(cell: MyTacsCell) {
        
        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
        
        // SET AS NEW SET
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(cell.setName, forKey: "customSet")
        
        if fingerAlreadyOut == true {
            
            if fingerIndexPath == indexPath {
                return
            }
            
            if self.tableView.cellForRowAtIndexPath(fingerIndexPath!) != nil {
                let fingerCell = self.tableView.cellForRowAtIndexPath(fingerIndexPath!) as! MyTacsCell
                
                UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    fingerCell.fingerImageView.transform = CGAffineTransformMakeTranslation(-160, 0)
                    }, completion: nil)
                delay(0.75, closure: { () -> () in
                    fingerCell.fingerImageView.alpha = 0
                })
            }
            
            fingerIndexPath = indexPath
            
            cell.fingerImageView.alpha = 1
            cell.fingerImageView.animation = "slideRight"
            cell.fingerImageView.duration = 1
            cell.fingerImageView.animate()
            
        } else {
            
            fingerIndexPath = indexPath
            
            cell.fingerImageView.alpha = 1
            cell.fingerImageView.animation = "slideRight"
            cell.fingerImageView.duration = 1
            cell.fingerImageView.animate()
            
            fingerAlreadyOut = true
            
        }
        
    }
    
    
    
    //MARK: - PAYMENT DELEGATE
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .Purchased, .Restored:
                    print("transaction ID \(transaction)");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .Failed:
                    print("Purchased Failed");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                default:
                    print("default");
                    break;
                }
            }
        }
        self.tableView.scrollsToTop = true
        self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
        loadingView.alpha = 0
        //stopLoader(self.view)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("COMPLETED TRANSACTIONS")
        self.tableView.reloadData()
        //stopLoader(self.view)
        self.tableView.scrollsToTop = true
        self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
        loadingView.alpha = 0
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        loadingView.frame.origin.x = scrollView.contentOffset.x
        loadingView.frame.origin.y = scrollView.contentOffset.y
    }
    
}
