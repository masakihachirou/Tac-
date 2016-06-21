//
//  ViewController.swift
//  Tac!
//
//  Created by Andrew Fashion on 7/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit
import GameKit

protocol RootDelegate {
    func didGetGameInvite()
}

class RootViewController: UIViewController, GameKitHelperDelegate {
    
    @IBOutlet weak var playComputerButton: DesignableButton!
    @IBOutlet weak var playFriendButton: DesignableButton!
    @IBOutlet weak var settingsButton: DesignableButton!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var challengeAIButton: DesignableButton!
    @IBOutlet weak var friendButton: DesignableButton!
    @IBOutlet weak var firearmsButton: DesignableButton!
    
    var tacModel = Tac()
    
    var delegate: RootDelegate?
    
    var inviteUsed = false
    
    var showingLoadingScreen = false
    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        userDefaults.setBool(false, forKey: "englishTranslate")
        
        if let englishTranslate = userDefaults.objectForKey("englishTranslate") as? Bool {
            if englishTranslate == true {
                translateButton.setTitle("日本語", forState: UIControlState.Normal)
                challengeAIButton.alpha = 1
                friendButton.alpha = 1
                firearmsButton.alpha = 1
            } else {
                translateButton.setTitle("ENG", forState: UIControlState.Normal)
                challengeAIButton.alpha = 0
                friendButton.alpha = 0
                firearmsButton.alpha = 0
            }
        }
        
        if let _ = userDefaults.objectForKey("customSet") as? String {
            print("you have a custom set already")
        } else {
            userDefaults.setObject("tacBundle0-set1", forKey: "customSet")
        }
        
        playComputerButton.alpha = 1
        playFriendButton.alpha = 1
        settingsButton.alpha = 1
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: PresentAuthenticationViewController, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setDelegate", name: "setDelegateInRoot", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "inviteAcceptedFromSender", name: "InviteAcceptedFromSender", object: nil)
        
        GameKitHelper.sharedInstance.authenticateLocalPlayer()
        
        tacModel.installFreeTacPieces()
        
        tacModel.downloadAllTacSets { (success) -> () in
            
            startLoader("Loading...", view: self.view)
            
            if success == true {
                stopLoader(self.view)
            }
        }
        
    }
    
    func setDelegate() {
        GameKitHelper.sharedInstance.delegate = self //for invite handling
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setDelegate()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func inviteAcceptedFromSender() {
        //show waiting screen
        showingLoadingScreen = true
        let loadingView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: self, options: nil)[0] as! LoadingScreen
        loadingView.backToMenuButton.alpha = 0
        loadingView.topText.text = "ゲームの準備"
        loadingView.subTitleText.text = "Preparing match"
        loadingView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
        self.view.addSubview(loadingView)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            loadingView.frame = CGRectMake(0, 0, loadingView.frame.size.width, loadingView.frame.size.height)
        })
    }
    
    func matchStarted() {
        //from friend invite
        if showingLoadingScreen == true {
            showingLoadingScreen = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                (self.view.subviews[self.view.subviews.count-1] as! LoadingScreen).frame = CGRectMake(0, self.view.frame.size.height, self.view.subviews[self.view.subviews.count-1].frame.size.width, self.view.subviews[self.view.subviews.count-1].frame.size.height)
                }, completion: { (value: Bool) -> Void in
                    self.view.subviews[self.view.subviews.count-1].removeFromSuperview()
                    //remove loading screen
            })
        }
        
        print("MATCH STARTED ACCEPTED INVITE ROOT SCREEN")
        
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("GameVC") as! GameViewController
        vc.acceptedInvite = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func matchCancelled() {
        
    }
    
    func matchEnded() {
        
    }
    
    func matchReceivedData(match: GKMatch, data: NSData, fromPlayer player: String) {
        
        print("MATCH DID RECEIVE DATA ROOT SCREEN")
        var lastTurn: Dictionary<String, AnyObject>?
        
        do {
            //var lastTurn = try NSJSONSerialization.JSONObjectWithData(data, options: nil) as! Dictionary<String, AnyObject>
            lastTurn = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject>
        } catch {
            
        }
        
        if !inviteUsed {
            inviteUsed = true
            NSNotificationCenter.defaultCenter().postNotificationName("InviteAccepted", object: nil, userInfo: lastTurn)
        }
        
        
    }
    
    @IBAction func playWithComputerButtonPressed(sender: AnyObject) {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("GameVC") as! GameViewController
        vc.versusComputer = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func playWithFriendsButtonPressed(sender: AnyObject) {
        //authenticateLocalPlayer()
        //GameKitHelper.sharedInstance.showGKGameCenterViewController(self)
        //let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.versusComputer = false
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("GameVC") as! GameViewController
        vc.versusComputer = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("GoToSettingsSegue", sender: self)
    }
    
    func showAuthenticationViewController() {
        let gameKitHelper = GameKitHelper.sharedInstance
        
        if let authenticationViewController = gameKitHelper.authenticationViewController {
            presentViewController(authenticationViewController, animated: true,
                completion: nil)
        }
    }
    
    @IBAction func translateButtonPressed(sender: UIButton) {
        if let englishTranslate = userDefaults.objectForKey("englishTranslate") as? Bool {
            if englishTranslate == true {
                userDefaults.setBool(false, forKey: "englishTranslate")
                translateButton.setTitle("ENG", forState: UIControlState.Normal)
                print("You have set to JAPANESE")
                challengeAIButton.alpha = 0
                friendButton.alpha = 0
                firearmsButton.alpha = 0
            } else {
                userDefaults.setBool(true, forKey: "englishTranslate")
                translateButton.setTitle("日本語", forState: UIControlState.Normal)
                print("You have set to ENGLISH")
                challengeAIButton.alpha = 1
                friendButton.alpha = 1
                firearmsButton.alpha = 1
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}

