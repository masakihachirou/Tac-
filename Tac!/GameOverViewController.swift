//
//  GameOverViewController.swift
//  Tac!
//
//  Created by Andrew Fashion on 8/5/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit

protocol GameOverDelegate {
    func gameOverDidDismiss(vc: GameOverViewController)
}

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var loaderView: LoaderView!
    @IBOutlet weak var loaderMainView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var rematchButton: DesignableButton!
    @IBOutlet weak var cancelButton: DesignableButton!
    @IBOutlet weak var goHomeButton: DesignableButton!
    
    @IBOutlet weak var anotherRoundButton: DesignableButton!
    @IBOutlet weak var goHomeButton2: DesignableButton!
    
    @IBOutlet weak var bubbleView: UIView!
    
    var delegate: GameOverDelegate?
    var versusComputer = false
    
    var animationTimer: NSTimer?
    var quitTimer: NSTimer?
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    var winner: String?
    var winnerFromGameCenter: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        goHomeButton.alpha = 0
        
        if let englishTranslate = userDefaults.objectForKey("englishTranslate") as? Bool {
            if englishTranslate == true {
                anotherRoundButton.alpha = 1
                goHomeButton2.alpha = 1
            } else {
                anotherRoundButton.alpha = 0
                goHomeButton2.alpha = 0
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetGameOverScreen", name: "Reset", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        loaderMainView.hidden = true
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        GameKitHelper.sharedInstance.multiplayerMatch?.disconnect()
        if let delegate = delegate {
            delegate.gameOverDidDismiss(self)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func rematch(sender : AnyObject!) {
        
        if versusComputer == false {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.quitRematchTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("quitRematchFind"), userInfo: nil, repeats: false)
            
            statusLabel.text = "再戦を準備します。"
            subTitleLabel.text = "Preparing rematch"
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.rematchButton.alpha = 0
                self.cancelButton.alpha = 0
            })
            
            delay(1, closure: { () -> () in
                self.goHomeButton.alpha = 1
                self.loaderMainView.hidden = false
                self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(2.75, target: self, selector: Selector("loadingTimer"), userInfo: nil, repeats: true)
                self.animationTimer?.fire()
            })
            
            NSNotificationCenter.defaultCenter().postNotificationName("Rematch", object: nil)
            
        } else {
            statusLabel.text = "再戦を準備します。"
            subTitleLabel.text = "Preparing rematch"
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.rematchButton.alpha = 0
                self.cancelButton.alpha = 0
            })
            
            delay(1, closure: { () -> () in
                self.goHomeButton.alpha = 1
                self.loaderMainView.hidden = false
                self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(2.75, target: self, selector: Selector("loadingTimer"), userInfo: nil, repeats: true)
                self.animationTimer?.fire()
            })
            
            NSNotificationCenter.defaultCenter().postNotificationName("Rematch", object: nil)
        }
        
    }
    
    @IBAction func goHomeButton(sender: AnyObject) {
        GameKitHelper.sharedInstance.multiplayerMatch?.disconnect()
        if let delegate = delegate {
            delegate.gameOverDidDismiss(self)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func quitRematchFind() {
        GameKitHelper.sharedInstance.multiplayerMatch?.disconnect()
        GameKitHelper.sharedInstance.delegate = nil
        if let delegate = delegate {
            delegate.gameOverDidDismiss(self)
        }
        print("QUITTING AND DISCONNECTING")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadingTimer() {
        loaderView.addStartLoaderAnimation()
    }
    
    func resetGameOverScreen() {
        print("RESET GAME OVER SCREEN CALLED")
        cancelButton.alpha = 1
        rematchButton.alpha = 1
        goHomeButton.alpha = 0
        statusLabel.text = "あなたの勝ち"

        if versusComputer {
            if winner == "x" {
                subTitleLabel.text = "You winner!"
            } else {
                subTitleLabel.text = "You were defeated!"
            }
        } else {
            
            subTitleLabel.text = "You were defeated!"
        }

        loaderMainView.hidden = true
        loaderView.removeAllAnimations()
        animationTimer?.invalidate()
    }
    
}
