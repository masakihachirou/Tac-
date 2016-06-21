
//
//  GameViewController.swift
//  Tac!
//
//  Created by Andrew Fashion on 7/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit
import GameKit

class GameViewController: UIViewController, UIAlertViewDelegate, GameKitHelperDelegate, GameOverDelegate {

    var shouldCancelAnimation = false
    var firstTime = true
    var showingLoadingScreen = false
    
    @IBOutlet weak var bottomBubble: DesignableView!
    @IBOutlet weak var bottomBubbleLabel: UILabel!
    @IBOutlet weak var topBubble: DesignableView!
    @IBOutlet weak var topBubbleText: UILabel!
    @IBOutlet var fields: [TTTImageView]!
    
    @IBOutlet var fieldOne : TTTImageView!
    @IBOutlet var fieldTwo : TTTImageView!
    @IBOutlet var fieldThree : TTTImageView!
    @IBOutlet var fieldFour : TTTImageView!
    @IBOutlet var fieldFive : TTTImageView!
    @IBOutlet var fieldSix : TTTImageView!
    @IBOutlet var fieldSeven : TTTImageView!
    @IBOutlet var fieldEight : TTTImageView!
    @IBOutlet var fieldNine : TTTImageView!
    
    @IBOutlet var tacCircles: [UIImageView]!
    @IBOutlet weak var circleOne: UIImageView!
    @IBOutlet weak var circleTwo: UIImageView!
    @IBOutlet weak var circleThree: UIImageView!
    @IBOutlet weak var circleFour: UIImageView!
    @IBOutlet weak var circleFive: UIImageView!
    @IBOutlet weak var circleSix: UIImageView!
    @IBOutlet weak var circleSeven: UIImageView!
    @IBOutlet weak var circleEight: UIImageView!
    @IBOutlet weak var circleNine: UIImageView!
    

    @IBOutlet var mainCircles: [UIImageView]!
    @IBOutlet weak var insideBoard: UIView!
    @IBOutlet weak var outsideBoard: UIView!
    @IBOutlet weak var meterView: MeterAnimationView!

    @IBOutlet weak var tabLeft: DesignableView!
    @IBOutlet weak var tabRight: DesignableView!
    @IBOutlet weak var xTabImageView: DesignableImageView!
    @IBOutlet weak var xImageView: UIImageView!
    @IBOutlet weak var oTabImageView: DesignableImageView!
    @IBOutlet weak var oImageView: UIImageView!
    
    var xTabActive = true
    var oTabActive = false
    
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var upArrow: UIImageView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var downArrow: UIImageView!
    
    var versusComputer = false
    var versusComputerGameOver = false
    var acceptedInvite = false
    
    var timer : NSTimer!
    var arrowTimerUp : NSTimer?
    var arrowTimerRight : NSTimer?
    var arrowTimerDown : NSTimer?

    var localRandomNumber = Int(arc4random())
    var currentPlayer: String = "x"
    var player1: String?
    var player2: String?
    var orderOfPlayers = [AnyObject]()
    
    var lastTurn = Dictionary<String, AnyObject>()
    
    var animator:UIDynamicAnimator!
    var snapBehaviour:UISnapBehavior!
    var stillDraggingLeftRight = false
    var stillDraggingUpDown = false
    var destination = CGPoint()
    
    var boardCircles = [Dictionary<String, AnyObject>]()
    var initialBoardFrame : CGRect!
    
    var movedUp = false
    var movedDown = false
    var movedLeft = false
    var movedRight = false
    
    var match: GKMatch!
    
    var winner: String?
    var meterCounter = 1
    var computerMeterCounter = 1
    
    var isGameBoardLocked = true
    var shiftAvailable = false
    
    var opponentsPiece = "default"
    var ownPiece = "default"
    var timerActive = false
    
    let gameOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("GameOverVC") as! GameOverViewController
    
    var blinkingArrowsTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "inviteAccepted:", name: "InviteAccepted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rematch", name: "Rematch", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goToMainMenu", name: "goToMainMenu", object: nil)
        
        let tapUp = UITapGestureRecognizer(target: self, action: "tapUp")
        let tapRight = UITapGestureRecognizer(target: self, action: "tapRight")
        let tapDown = UITapGestureRecognizer(target: self, action: "tapDown")
        let tapLeft = UITapGestureRecognizer(target: self, action: "tapLeft")
        
        upArrow.addGestureRecognizer(tapUp)
        rightArrow.addGestureRecognizer(tapRight)
        downArrow.addGestureRecognizer(tapDown)
        leftArrow.addGestureRecognizer(tapLeft)
        
        if versusComputer == false {
            
            GameKitHelper.sharedInstance.delegate = self
            
            if acceptedInvite == true {
                print("INVITE ACCEPTED: match started")
                match = GameKitHelper.sharedInstance.multiplayerMatch
                sendInitialData()
                return
            } else {
                GameKitHelper.sharedInstance.findMatch(2, maxPlayers: 2, presentingViewController: self, delegate: self)
            }
            
            // So phone doesn't sleep
            UIApplication.sharedApplication().idleTimerDisabled = true
            
        } else if versusComputer == true {
    
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.versusComputer = true
            //currentPlayer = "x"
            
        }
            
        tabLeft.alpha = 1
        tabRight.alpha = 1
        
        for circle in self.mainCircles {
            circle.alpha = 0
        }
        
        xTabImageView.alpha = 0
        xImageView.image = UIImage(named: "tabX")
        
        oTabImageView.alpha = 0
        oImageView.image = UIImage(named: "tabO")
        
        gameOverVC.delegate = self
        gameOverVC.view.backgroundColor = UIColor.clearColor()
        gameOverVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        if versusComputer == true {
            gameOverVC.versusComputer = true
        }
        
        bottomBubble.alpha = 0
        topBubble.alpha = 0
        topBubble.hidden = false

        lastTurn["player"] = ""
        
        meterView.addStartAnimation()
        
        self.fields = [fieldOne, fieldTwo, fieldThree, fieldFour, fieldFive, fieldSix, fieldSeven, fieldEight, fieldNine]

        setupGameLogic()
        setupGameUI()
        
        // Create the Dynamic Animator
        animator = UIDynamicAnimator(referenceView: self.view)
        
        self.initialBoardFrame = self.insideBoard.frame
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if versusComputer {
            setPlayersForComputerAI()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.gameFirstTime = false
        
        if versusComputer == true {
        
            xTabImageView.alpha = 1
            xImageView.image = UIImage(named: "tabX-pink")
            oTabImageView.alpha = 1
            oImageView.image = UIImage(named: "tabO-blue")
            
//            if currentPlayer == "x" {
//                xTabActive = true
//                oTabActive = false
//                // SLIDE OUT O
//                UIView.animateWithDuration(1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//                    
//                    self.oTabImageView.transform = CGAffineTransformMakeTranslation(185, 0)
//                    self.oImageView.transform = CGAffineTransformMakeTranslation(185, 0)
//                    
//                    }, completion: nil)
//            } else {
//                xTabActive = false
//                oTabActive = true
//                // SLIDE OUT X
//                UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//                    
//                    self.xTabImageView.transform = CGAffineTransformMakeTranslation(-180, 0)
//                    self.xImageView.transform = CGAffineTransformMakeTranslation(-185, 0)
//                    
//                    self.xTabImageView.alpha = 0
//                    
//                    }, completion: nil)
//            }
            
            
            
        }
        
    }
    
    func setupGameLogic() {
        for var i = 0; i < 9; i++ {
            let circle = ["selection": "unchecked"]
            self.boardCircles.append(circle)
        }
    }
    
    func pickRandomPieceForPlayer() -> String {
        let array = ["x", "o"]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        print(array[randomIndex])
        return array[randomIndex]
    }
    
    func setPlayersForComputerAI() {
        currentPlayer = pickRandomPieceForPlayer()
        
        xTabImageView.alpha = 1
        xImageView.image = UIImage(named: "tabX-pink")
        oTabImageView.alpha = 1
        oImageView.image = UIImage(named: "tabO-blue")
        
        if currentPlayer == "x" {
            xTabActive = true
            oTabActive = false
            // SLIDE OUT O
            UIView.animateWithDuration(1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.oTabImageView.transform = CGAffineTransformMakeTranslation(185, 0)
                self.oImageView.transform = CGAffineTransformMakeTranslation(185, 0)
                
                }, completion: nil)
        } else {
            xTabActive = false
            oTabActive = true
            // SLIDE OUT X
            UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.xTabImageView.transform = CGAffineTransformMakeTranslation(-180, 0)
                self.xImageView.transform = CGAffineTransformMakeTranslation(-185, 0)
                
                self.xTabImageView.alpha = 0
                
                }, completion: nil)
        }
        
        if currentPlayer == "x" {
            isGameBoardLocked = false
            player1 = "x"
            player2 = "o"
            print("PLAYER 1: \(player1) - PLAYER 2: \(player2)")
        } else {
            isGameBoardLocked = true
            player1 = "x"
            player2 = "o"
            print("PLAYER 1: \(player1) - PLAYER 2: \(player2)")
            if currentPlayer == "o" {
                delay(1, closure: { () -> () in
                    self.makeComputerMove()
                })
            }
        }
    }
    
    func inviteAccepted(object: NSNotification) {
        print("post notification !!!!")
        
        if let lastTurn = object.userInfo as? Dictionary<String, AnyObject> {
            setInitialPlayers(lastTurn["player"] as! String, receivedNumber: lastTurn["randomNumber"] as! Int)
            
        } else {
            print("NO DATA")
        }
        
    }
    
    func setupGameUI() {
        for field in fields {
            let tap = UITapGestureRecognizer(target: self, action: "fieldTapped:")
            tap.numberOfTapsRequired = 1
            field.addGestureRecognizer(tap)
            //field.layer.cornerRadius = field.frame.size.width / 2
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        insideBoard.addGestureRecognizer(pan)
    }
    
    func updateBoardUI() {
        self.insideBoard.frame = self.initialBoardFrame
        
        var fieldsImages = [UIImage]()
        var playerData = [String]()
        for field in fields {
            if let image = field.image {
                fieldsImages.append(field.image!)
                if let player = field.player {
                    playerData.append(field.player!)
                }
                else {
                    playerData.append("")
                }
            }
            else {
                fieldsImages.append(UIImage())
                playerData.append("")
            }
        }
        
        for var i = 0; i < 9; i++ {
            if movedUp {
                if i > 5 {
                    fields[i].image = nil
                    fields[i].player = nil
                }
                else {
                    fields[i].image = fieldsImages[i+3]
                    fields[i].player = playerData[i+3]
                    if fields[i].player == "" {
                        fields[i].player = nil
                    }
                }
            }
            else if movedDown {
                if i < 3 {
                    fields[i].image = nil
                    fields[i].player = nil
                }
                else {
                    fields[i].image = fieldsImages[i-3]
                    fields[i].player = playerData[i-3]
                    if fields[i].player == "" {
                        fields[i].player = nil
                    }
                }
            }
            else if movedLeft {
                if i == 2 || i == 5 || i == 8 {
                    fields[i].image = nil
                    fields[i].player = nil
                }
                else {
                    fields[i].image = fieldsImages[i+1]
                    fields[i].player = playerData[i+1]
                    if fields[i].player == "" {
                        fields[i].player = nil
                    }
                }
            }
            else if movedRight {
                if i == 0 || i == 3 || i == 6 {
                    fields[i].image = nil
                    fields[i].player = nil
                }
                else {
                    fields[i].image = fieldsImages[i-1]
                    fields[i].player = playerData[i-1]
                    if fields[i].player == "" {
                        fields[i].player = nil
                    }
                }
            }
        }
        
        movedUp = false
        movedDown = false
        movedLeft = false
        movedRight = false
    }
    
    func fieldTapped(sender: UITapGestureRecognizer) {
        
        var playerWhoMoved: String?
        
        // CHECK IF GAMEBOARD IS LOCKED
        if isGameBoardLocked == true {
            self.topBubble.alpha = 1
            
            SpringAnimation.springWithDelay(1, delay: 1, animations: { () -> Void in
                self.topBubble.alpha = 0
            })
            
            return
        }
        
        let tappedField = sender.view as! TTTImageView
        
        if tappedField.player == nil {

            // LOCK THE BOARD FOR THE PERSON WHO JUST MOVED
            if player1 == GKLocalPlayer.localPlayer().playerID {
                isGameBoardLocked = true
            } else {
                isGameBoardLocked = false
            }
            
            tappedField.setThePlayer(currentPlayer, withPiece: ownPiece)
            bumpUpMeter()
            self.boardCircles[tappedField.tag]["selection"] = currentPlayer
            setupTabs("", playerID: "")
            checkForWinner()
            
            
            if versusComputerGameOver == false {
            
                if versusComputer == false {
                    // CHECK WHO IS MOVING
                    if player1 == GKLocalPlayer.localPlayer().playerID {
                        playerWhoMoved = player1
                        sendMovesToOtherPlayer(tappedField.tag, player: playerWhoMoved!, tacPiece: "x")
                    } else if player2 == GKLocalPlayer.localPlayer().playerID {
                        playerWhoMoved = player2
                        sendMovesToOtherPlayer(tappedField.tag, player: playerWhoMoved!, tacPiece: "o")
                    }
                } else {
                    if currentPlayer == "x" {
                        isGameBoardLocked = true
                        //playerWhoMoved = "x"
                        currentPlayer = "o"
                        makeComputerMove()
                    } else {
                        
                    }
                }
                
            }
            
            
        }
        
        
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if shiftAvailable {
            
            
            if isGameBoardLocked == true {
                
                topBubble.alpha = 1
                
                SpringAnimation.springWithDelay(1, delay: 1, animations: { () -> Void in
                    self.topBubble.alpha = 0
                })
                
                return
            }
            
            for circle in self.mainCircles {
                circle.alpha = 1
            }
            
            if snapBehaviour != nil {
                animator.removeBehavior(snapBehaviour)
            }
            
            if sender.state == UIGestureRecognizerState.Began {
                UIView.animateWithDuration(1, animations: { () -> Void in
                    for circle in self.mainCircles {
                        circle.alpha = 0.2
                    }
                })
            }
            
            self.view.bringSubviewToFront(sender.view!)
            var translation = sender.translationInView(self.view!)
            
            let threshold : CGFloat = 5.0
            let threshold2 : CGFloat = 20.0
            var movingLeftRight = true
            
            if abs(translation.x) >= threshold || abs(translation.y) >= threshold {
                
                if abs(translation.y) >= abs(translation.x) {
                    movingLeftRight = false
                }
                
                if movingLeftRight {
                    
                    stillDraggingLeftRight = true
                    sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, outsideBoard.center.y)
                    
                    if abs(abs(sender.view!.center.x) - abs(outsideBoard.center.x)) <= 40 {
                        destination = CGPointMake(self.view.center.x, self.view.center.y)
                        movedLeft = false
                        movedRight = false
                        movedUp = false
                        movedDown = false
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.fieldOne.alpha = 1
                            self.fieldTwo.alpha = 1
                            self.fieldThree.alpha = 1
                            self.fieldFour.alpha = 1
                            self.fieldFive.alpha = 1
                            self.fieldSix.alpha = 1
                            self.fieldSeven.alpha = 1
                            self.fieldEight.alpha = 1
                            self.fieldNine.alpha = 1
                            
                            self.circleOne.alpha = 1
                            self.circleTwo.alpha = 1
                            self.circleThree.alpha = 1
                            self.circleFour.alpha = 1
                            self.circleFive.alpha = 1
                            self.circleSix.alpha = 1
                            self.circleSeven.alpha = 1
                            self.circleEight.alpha = 1
                            self.circleNine.alpha = 1
                        })
                    } else if sender.view!.center.x >= outsideBoard.center.x {
                        
                        destination = CGPointMake(self.view.center.x + 84, self.view.center.y)
                        movedRight = true
                        
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.fieldThree.alpha = 0.25
                            self.fieldSix.alpha = 0.25
                            self.fieldNine.alpha = 0.25
                            self.circleThree.alpha = 0.25
                            self.circleSix.alpha = 0.25
                            self.circleNine.alpha = 0.25
                        })
                    } else {
                        destination = CGPointMake(self.view.center.x - 84, self.view.center.y)
                        movedLeft = true
                        
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.fieldOne.alpha = 0.25
                            self.fieldFour.alpha = 0.25
                            self.fieldSeven.alpha = 0.25
                            self.circleOne.alpha = 0.25
                            self.circleFour.alpha = 0.25
                            self.circleSeven.alpha = 0.25
                        })
                    }
                    
                } else { //up/down
                    
                    stillDraggingUpDown = true
                    sender.view!.center = CGPointMake(outsideBoard.center.x, sender.view!.center.y + translation.y)
                    
                    if abs(abs(sender.view!.center.y) - abs(outsideBoard.center.y)) <= 40 {
                        movedLeft = false
                        movedRight = false
                        movedUp = false
                        movedDown = false
                        destination = CGPointMake(self.view.center.x, self.view.center.y)
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.fieldOne.alpha = 1
                            self.fieldTwo.alpha = 1
                            self.fieldThree.alpha = 1
                            self.fieldFour.alpha = 1
                            self.fieldFive.alpha = 1
                            self.fieldSix.alpha = 1
                            self.fieldSeven.alpha = 1
                            self.fieldEight.alpha = 1
                            self.fieldNine.alpha = 1
                            
                            self.circleOne.alpha = 1
                            self.circleTwo.alpha = 1
                            self.circleThree.alpha = 1
                            self.circleFour.alpha = 1
                            self.circleFive.alpha = 1
                            self.circleSix.alpha = 1
                            self.circleSeven.alpha = 1
                            self.circleEight.alpha = 1
                            self.circleNine.alpha = 1
                        })
                    } else if sender.view!.center.y >= outsideBoard.center.y {
                        destination = CGPointMake(self.view.center.x, self.view.center.y + 86)
                        movedDown = true
                        
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.fieldSeven.alpha = 0.25
                            self.fieldEight.alpha = 0.25
                            self.fieldNine.alpha = 0.25
                            self.circleSeven.alpha = 0.25
                            self.circleEight.alpha = 0.25
                            self.circleNine.alpha = 0.25
                        })
                    } else {
                        destination = CGPointMake(self.view.center.x, self.view.center.y - 86)
                        movedUp = true
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.fieldOne.alpha = 0.25
                            self.fieldTwo.alpha = 0.25
                            self.fieldThree.alpha = 0.25
                            self.circleOne.alpha = 0.25
                            self.circleTwo.alpha = 0.25
                            self.circleThree.alpha = 0.25
                        })
                    }
                }
                
                sender.setTranslation(CGPointZero, inView: self.view!)
            }
            
            // THIS IS WHAT HAPPENS WHEN THE USER IS DONE DRAGGING THE BOARD
            if sender.state == UIGestureRecognizerState.Ended {
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.fieldOne.alpha = 1
                    self.fieldTwo.alpha = 1
                    self.fieldThree.alpha = 1
                    self.fieldFour.alpha = 1
                    self.fieldFive.alpha = 1
                    self.fieldSix.alpha = 1
                    self.fieldSeven.alpha = 1
                    self.fieldEight.alpha = 1
                    self.fieldNine.alpha = 1
                    
                    self.circleOne.alpha = 1
                    self.circleTwo.alpha = 1
                    self.circleThree.alpha = 1
                    self.circleFour.alpha = 1
                    self.circleFive.alpha = 1
                    self.circleSix.alpha = 1
                    self.circleSeven.alpha = 1
                    self.circleEight.alpha = 1
                    self.circleNine.alpha = 1
                })
                
                if movedUp || movedDown || movedLeft || movedRight {
                    stillDraggingLeftRight = false
                    stillDraggingUpDown = false
                    
                    UIView.animateWithDuration(1, animations: { () -> Void in
                        for circle in self.mainCircles {
                            circle.alpha = 1
                        }
                    })
                    
                    var playerWhoMoved: String!
                    
                    if versusComputer == false {
                    
                        // CHECK WHO IS MOVING
                        if player1 == GKLocalPlayer.localPlayer().playerID {
                            playerWhoMoved = player1
                        } else if player2 == GKLocalPlayer.localPlayer().playerID {
                            playerWhoMoved = player2
                        }
                            
                    } else {
                        
                        if currentPlayer == "x" {
                            playerWhoMoved = "o"
                        } else {
                            playerWhoMoved = "x"
                        }
                        
                    }
                    
                    var shiftDict = ["player": playerWhoMoved, "tac": self.currentPlayer]
                    
                    if movedUp {
                        shiftDict["shift"] = "up"
                    }
                    else if movedDown {
                        shiftDict["shift"] = "down"
                    }
                    else if movedLeft {
                        shiftDict["shift"] = "left"
                    }
                    else if movedRight {
                        shiftDict["shift"] = "right"
                    }
                    
                    lastTurn = shiftDict
                    
                    if versusComputer == false {
                        let moveData = try! NSJSONSerialization.dataWithJSONObject(shiftDict, options: NSJSONWritingOptions.PrettyPrinted)
                        
                        try! GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(moveData, withDataMode: GKMatchSendDataMode.Reliable)
                    }
                    
                    isGameBoardLocked = true
                    
                    usedShiftRules()
                    
                } else {
                    
                    destination = CGPointMake(self.view.center.x, self.view.center.y)
                    
                    UIView.animateWithDuration(0.5, animations:
                        {
                            self.insideBoard.center = self.destination
                        }, completion: {
                            (value: Bool) in
                            
                    })
                }
                
            }
            
            
            
            
        }
    }
    
    func tapUp() {
        if shiftAvailable {
            if isGameBoardLocked == true {
                topBubble.alpha = 1
                SpringAnimation.springWithDelay(1, delay: 1, animations: { () -> Void in
                    self.topBubble.alpha = 0
                })
                return
            }
            performOpponentsShift("up")
            usedShiftRules()
        }
    }
    
    func tapRight() {
        if shiftAvailable {
            if isGameBoardLocked == true {
                topBubble.alpha = 1
                SpringAnimation.springWithDelay(1, delay: 1, animations: { () -> Void in
                    self.topBubble.alpha = 0
                })
                return
            }
            performOpponentsShift("right")
            usedShiftRules()
        }
    }
    
    func tapDown() {
        if shiftAvailable {
            if isGameBoardLocked == true {
                topBubble.alpha = 1
                SpringAnimation.springWithDelay(1, delay: 1, animations: { () -> Void in
                    self.topBubble.alpha = 0
                })
                return
            }
            performOpponentsShift("down")
            usedShiftRules()
        }
    }
    
    func tapLeft() {
        if shiftAvailable {
            if isGameBoardLocked == true {
                topBubble.alpha = 1
                SpringAnimation.springWithDelay(1, delay: 1, animations: { () -> Void in
                    self.topBubble.alpha = 0
                })
                return
            }
            performOpponentsShift("left")
            usedShiftRules()
        }
    }
    
    func usedShiftRules() {
        isGameBoardLocked = true
        shiftAvailable = false
        updateBoardUI()
        meterView.addPowerDownAnimation()
        shouldCancelAnimation = true
        blinkingArrowsTimer?.invalidate()
        arrowTimerUp?.invalidate()
        arrowTimerRight?.invalidate()
        arrowTimerDown?.invalidate()
        resetArrows()
        SpringAnimation.spring(1, animations: { () -> Void in
            self.bottomBubble.alpha = 0
        })
        meterCounter = 1
        setupTabs("", playerID: "")
        if versusComputer == true {
            currentPlayer = "o"
            makeComputerMove()
        }
    }
    
    func checkForWinner() {
        
        // CHECKING FIRST ROW
        if fieldOne.player == "x" && fieldTwo.player == "x" && fieldThree.player == "x" {
            winner = "x"
            fieldOne.winningField = true
            fieldTwo.winningField = true
            fieldThree.winningField = true
        }
        
        else if fieldOne.player == "o" && fieldTwo.player == "o" && fieldThree.player == "o" {
            winner = "o"
            fieldOne.winningField = true
            fieldTwo.winningField = true
            fieldThree.winningField = true
        }
        
        // CHECKING SECOND ROW
        else if fieldFour.player == "x" && fieldFive.player == "x" && fieldSix.player == "x" {
            winner = "x"
            fieldFour.winningField = true
            fieldFive.winningField = true
            fieldSix.winningField = true
        }
        
        else if fieldFour.player == "o" && fieldFive.player == "o" && fieldSix.player == "o" {
            winner = "o"
            fieldFour.winningField = true
            fieldFive.winningField = true
            fieldSix.winningField = true
        }
        
        // CHECKING THIRD ROW
        else if fieldSeven.player == "x" && fieldEight.player == "x" && fieldNine.player == "x" {
            winner = "x"
            fieldSeven.winningField = true
            fieldEight.winningField = true
            fieldNine.winningField = true
        }
        
        else if fieldSeven.player == "o" && fieldEight.player == "o" && fieldNine.player == "o" {
            winner = "o"
            fieldSeven.winningField = true
            fieldEight.winningField = true
            fieldNine.winningField = true
        }
        
        // CHECKING LEFT ROW
        else if fieldOne.player == "x" && fieldFour.player == "x" && fieldSeven.player == "x" {
            winner = "x"
            fieldOne.winningField = true
            fieldFour.winningField = true
            fieldSeven.winningField = true
        }
        
        else if fieldOne.player == "o" && fieldFour.player == "o" && fieldSeven.player == "o" {
            winner = "o"
            fieldOne.winningField = true
            fieldFour.winningField = true
            fieldSeven.winningField = true
        }
        
        // CHECKING MIDDLE ROW
        else if fieldTwo.player == "x" && fieldFive.player == "x" && fieldEight.player == "x" {
            winner = "x"
            fieldTwo.winningField = true
            fieldFive.winningField = true
            fieldEight.winningField = true
        }
        
        else if fieldTwo.player == "o" && fieldFive.player == "o" && fieldEight.player == "o" {
            winner = "o"
            fieldTwo.winningField = true
            fieldFive.winningField = true
            fieldEight.winningField = true
        }
        
        // CHECKING RIGHT ROW
        else if fieldThree.player == "x" && fieldSix.player == "x" && fieldNine.player == "x" {
            winner = "x"
            fieldThree.winningField = true
            fieldSix.winningField = true
            fieldNine.winningField = true
        }
        
        else if fieldThree.player == "o" && fieldSix.player == "o" && fieldNine.player == "o" {
            winner = "o"
            fieldThree.winningField = true
            fieldSix.winningField = true
            fieldNine.winningField = true
        }
        
        // CHECKING DIAGONAL TOP LEFT TO BOTTOM RIGHT
        else if fieldOne.player == "x" && fieldFive.player == "x" && fieldNine.player == "x" {
            winner = "x"
            fieldOne.winningField = true
            fieldFive.winningField = true
            fieldNine.winningField = true
        }
        
        else if fieldOne.player == "o" && fieldFive.player == "o" && fieldNine.player == "o" {
            winner = "o"
            fieldOne.winningField = true
            fieldFive.winningField = true
            fieldNine.winningField = true
        }
        
        // CHECKING DIAGONAL TOP RIGHT TO BOTTOM LEFT
        else if fieldThree.player == "x" && fieldFive.player == "x" && fieldSeven.player == "x" {
            winner = "x"
            fieldThree.winningField = true
            fieldFive.winningField = true
            fieldSeven.winningField = true
        }
        
        else if fieldThree.player == "o" && fieldFive.player == "o" && fieldSeven.player == "o" {
            winner = "o"
            fieldThree.winningField = true
            fieldFive.winningField = true
            fieldSeven.winningField = true
        }
        else if lastTurn["player"] as? String != GKLocalPlayer.localPlayer().playerID && fieldOne.player != nil && fieldTwo.player != nil && fieldThree.player != nil && fieldFour.player != nil && fieldFive.player != nil && fieldSix.player != nil && fieldSeven.player != nil && fieldEight.player != nil && fieldNine.player != nil {
                //cat game
            while meterCounter < 7 {
                self.bumpUpMeter()
            }
        }
        
        if let winner = winner {
            print(winner + " won")
            
            for field in fields {
                if field.winningField == false && field.player != nil {
                    //field.image = convertToBlackAndWhite(fieldOne.image!)
                }
            }
            
            if versusComputer == true {
                versusComputerGameOver = true
                if player1 == self.winner {
                    gameOverVC.subTitleLabel.text = "You winner!"
                } else {
                    gameOverVC.subTitleLabel.text = "You defeated!"
                }
            } else {
                if player1 == GKLocalPlayer.localPlayer().playerID! && self.winner == "x" {
                    gameOverVC.subTitleLabel.text = "You winner!"
                } else if player1 == GKLocalPlayer.localPlayer().playerID! && self.winner == "o" {
                    gameOverVC.subTitleLabel.text = "You defeated!"
                }
                
                if player2 == GKLocalPlayer.localPlayer().playerID! && self.winner == "x" {
                    gameOverVC.subTitleLabel.text = "You defeated!"
                } else if player2 == GKLocalPlayer.localPlayer().playerID! && self.winner == "o" {
                    gameOverVC.subTitleLabel.text = "You winner!"
                }
            }
            
            isGameBoardLocked = true
            meterCounter = 1
            shiftAvailable = false
            bottomBubble.alpha = 1
            
            if currentPlayer == winner {
                bottomBubbleLabel.text = "あなたが勝つ"
            } else {
                bottomBubbleLabel.text = "良いゲーム"
            }
            
            blinkingArrowsTimer?.invalidate()
            resetArrows()
            meterView.addPowerDownAnimation()
            
            
            
            // RESET OPPONENTS CUSTOM SET
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(nil, forKey: "opponentCustomSet")
            
            for field in fields {
                if field.winningField != true {
                    field.alpha = 1
                }
            }
            
            gameOverVC.winner = self.winner
            
            self.winner = nil

            fieldOne.player = nil
            fieldTwo.player = nil
            fieldThree.player = nil
            fieldFour.player = nil
            fieldFive.player = nil
            fieldSix.player = nil
            fieldSeven.player = nil
            fieldEight.player = nil
            fieldNine.player = nil
            
            fieldOne.winningField = false
            fieldTwo.winningField = false
            fieldThree.winningField = false
            fieldFour.winningField = false
            fieldFive.winningField = false
            fieldSix.winningField = false
            fieldSeven.winningField = false
            fieldEight.winningField = false
            fieldNine.winningField = false
            
            delay(2, closure: { () -> () in
                self.presentViewController(self.gameOverVC, animated: true, completion: nil)
            })
        }
    }
    
    func gameOverDidDismiss(vc: GameOverViewController) {
        delay(0.5, closure: { () -> () in
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    func rematch() {
        
        if versusComputer == false {
        
            GameKitHelper.sharedInstance.multiplayerMatch?.rematchWithCompletionHandler({ (match: GKMatch?, error: NSError?) -> Void in
                
                print("REMATCH STARTED")
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.quitRematchTimer?.invalidate()
                
                self.meterCounter = 1
                self.shiftAvailable = false
                self.resetArrows()
                self.bottomBubble.alpha = 0
                self.boardCircles = []
                
                for field in self.fields {
                    field.player = nil
                    field.image = nil
                    field.alpha = 1
                }
                
                self.setupGameLogic()
                
                self.gameOverVC.dismissViewControllerAnimated(true, completion: nil)
                
                // RESET THE GAME OVER SCREEN
                NSNotificationCenter.defaultCenter().postNotificationName("Reset", object: nil)
                
                // TAB SHIT MOTHER FUCKER
                if self.xTabActive == false {
                    
                    self.xTabActive = true
                    self.oTabActive = false
                    
                    self.xTabImageView.alpha = 1
                    
                    // SLIDE OUT O
                    UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        
                        self.oTabImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                        self.oImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                        
                        }, completion: nil)
                    
                    // SLIDE IN X
                    UIView.animateWithDuration(1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        
                        self.xTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                        self.xImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                        
                        }, completion: nil)
                    
                } else {
                    
                    // SLIDE IN X
                    UIView.animateWithDuration(1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        
                        self.xTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                        self.xImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                        
                        }, completion: nil)
                    
                    // SLIDE OUT O
                    UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        
                        self.oTabImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                        self.oImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                        
                        }, completion: nil)
                    
                }
                
                GameKitHelper.sharedInstance.delegate?.matchStarted()
     
            })
            
        } else if versusComputer == true {
            print("VERSUS COMPUTER IS TRUE")
            self.isGameBoardLocked = false
            self.versusComputerGameOver = false
            setPlayersForComputerAI()
            
            self.versusComputer = true
            self.meterCounter = 1
            self.computerMeterCounter = 1
            self.shiftAvailable = false
            self.resetArrows()
            self.bottomBubble.alpha = 0
            self.boardCircles = []
            
            for field in self.fields {
                field.player = nil
                field.image = nil
                field.alpha = 1
            }
            
            self.setupGameLogic()
            
            self.gameOverVC.dismissViewControllerAnimated(true, completion: nil)
            self.gameOverVC.goHomeButton.hidden = true
            
            // RESET THE GAME OVER SCREEN
            NSNotificationCenter.defaultCenter().postNotificationName("Reset", object: nil)
            
            if currentPlayer == "x" {
                self.xTabActive = true
                self.oTabActive = false
                
                self.xTabImageView.alpha = 1
                
                // SLIDE OUT O
                UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    
                    self.oTabImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                    self.oImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                    
                    }, completion: nil)
                
                // SLIDE IN X
                UIView.animateWithDuration(1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    
                    self.xTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                    self.xImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                    
                    }, completion: nil)
            } else {
                xTabActive = false
                oTabActive = true
                
                oTabImageView.alpha = 1
                
                // SLIDE IN O
                UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.oTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                    self.oImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                    }, completion: nil)
                
                
                // SLIDE OUT X
                UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    
                    self.xTabImageView.transform = CGAffineTransformMakeTranslation(-180, 0)
                    self.xImageView.transform = CGAffineTransformMakeTranslation(-185, 0)
                    
                    self.xTabImageView.alpha = 0
                    
                    }, completion: nil)
            }
            
//            
//            // TAB SHIT MOTHER FUCKER
//            if self.xTabActive == false {
//                
//                self.xTabActive = true
//                self.oTabActive = false
//                
//                self.xTabImageView.alpha = 1
//                
//                // SLIDE OUT O
//                UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//                    
//                    self.oTabImageView.transform = CGAffineTransformMakeTranslation(180, 0)
//                    self.oImageView.transform = CGAffineTransformMakeTranslation(180, 0)
//                    
//                    }, completion: nil)
//                
//                // SLIDE IN X
//                UIView.animateWithDuration(1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//                    
//                    self.xTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
//                    self.xImageView.transform = CGAffineTransformMakeTranslation(0, 0)
//                    
//                    }, completion: nil)
//                
//            } else {
//                
//                // SLIDE IN X
//                UIView.animateWithDuration(1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//                    
//                    self.xTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
//                    self.xImageView.transform = CGAffineTransformMakeTranslation(0, 0)
//                    
//                    }, completion: nil)
//                
//                // SLIDE OUT O
//                UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//                    
//                    self.oTabImageView.transform = CGAffineTransformMakeTranslation(180, 0)
//                    self.oImageView.transform = CGAffineTransformMakeTranslation(180, 0)
//                    
//                    }, completion: nil)
//                
//            }
            
            

        }
    }

    func showWinAlert() {
        let alert = UIAlertView(title: "You Won!", message: "Congratulations.", delegate: self, cancelButtonTitle: "Ok")
    }
    
    func matchStarted() {
        print("match started")
        
        self.match = GameKitHelper.sharedInstance.multiplayerMatch
        sendInitialData()
        
    }
    
    func matchEnded() {
        print("match ended")
    }
    
    func matchCancelled() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func performOpponentsShift(shift : String) {
        
        setupTabs("", playerID: "")
        
        if shift == "up" {
            movedUp = true
            self.destination = CGPointMake(self.view.center.x, self.view.center.y - 86)
        }
        else if shift == "down" {
            movedDown = true
            self.destination = CGPointMake(self.view.center.x, self.view.center.y + 86)
        }
        else if shift == "left" {
            movedLeft = true
            self.destination = CGPointMake(self.view.center.x - 84, self.view.center.y)
        }
        else if shift == "right" {
            movedRight = true
            self.destination = CGPointMake(self.view.center.x + 84, self.view.center.y)
        }
        
        UIView.animateWithDuration(0.5, animations:
            {
                self.insideBoard.center = self.destination
            }, completion: {
                (value: Bool) in
                self.insideBoard.center = self.outsideBoard.center
                self.updateBoardUI()
                self.bumpUpMeter()
        })
        
        if versusComputer == true {
            
        }
        
    }
    
    func bumpUpMeter() {
        if meterCounter == 1 {
            meterView.addDash1Animation()
            meterCounter += 1
            if versusComputer == true {
                computerMeterCounter += 1
            }
        } else if meterCounter == 2 {
            meterView.addDash2Animation()
            meterCounter += 1
            if versusComputer == true {
                computerMeterCounter += 1
            }
        } else if meterCounter == 3 {
            meterView.addDash3Animation()
            meterCounter += 1
            if versusComputer == true {
                computerMeterCounter += 1
            }
        } else if meterCounter == 4 {
            meterView.addDash4Animation()
            meterCounter += 1
            if versusComputer == true {
                computerMeterCounter += 1
            }
        } else if meterCounter == 5 {
            meterView.addDash5Animation()
            meterCounter += 1
            if versusComputer == true {
                computerMeterCounter += 1
            }
        } else if meterCounter == 6 {
            meterView.addDash6Animation()
            meterCounter += 1
            if versusComputer == true {
                computerMeterCounter += 1
            }
            
            shiftAvailable = true
            blinkingArrowsTimer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: Selector("blinkingArrows"), userInfo: nil, repeats: true)
            blinkingArrowsTimer?.fire()
        } else {
            meterCounter += 1
            if versusComputer == true {
                computerMeterCounter += 1
            }
        }
        
        print("YOUR METER COUNTER: \(meterCounter)")
    }
    
    func goToMainMenu() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.gameFirstTime = true
        if showingLoadingScreen {
            showingLoadingScreen = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                (self.view.subviews[self.view.subviews.count-1] as! LoadingScreen).frame = CGRectMake(0, self.view.frame.size.height, self.view.subviews[self.view.subviews.count-1].frame.size.width, self.view.subviews[self.view.subviews.count-1].frame.size.height)
                }, completion: { (value: Bool) -> Void in
                    self.view.subviews[self.view.subviews.count-1].removeFromSuperview()
                    //remove loading screen
                    self.navigationController?.popToRootViewControllerAnimated(true)
            })
        }
        else {
            self.navigationController?.popToRootViewControllerAnimated(true)

        }
    }
    
    func timerEnded() {
        GameKitHelper.sharedInstance.multiplayerMatch?.disconnect()
        self.goToMainMenu()
    }
    
    func matchReceivedData(match: GKMatch, data: NSData, fromPlayer player: String) {
        
        print("MATCH DID RECEIVE DATA")
        
        lastTurn = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let playerStatus = lastTurn["playerStatusChanged"] as? String {
            if playerStatus == "player left app" {
                //show waiting screen
                showingLoadingScreen = true
                let loadingView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: self, options: nil)[0] as! LoadingScreen
                loadingView.backToMenuButton.addTarget(self, action: Selector("goToMainMenu"), forControlEvents: UIControlEvents.TouchUpInside)
                loadingView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
                
                
                self.view.addSubview(loadingView)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    loadingView.frame = CGRectMake(0, 0, loadingView.frame.size.width, loadingView.frame.size.height)
                })
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("timerEnded"), userInfo: nil, repeats: false);
            }
            else if playerStatus == "player came back to app" {
                self.timer.invalidate()
                //self.timer = nil
                showingLoadingScreen = false
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    (self.view.subviews[self.view.subviews.count-1] as! LoadingScreen).frame = CGRectMake(0, self.view.frame.size.height, self.view.subviews[self.view.subviews.count-1].frame.size.width, self.view.subviews[self.view.subviews.count-1].frame.size.height)
                    }, completion: { (value: Bool) -> Void in
                        self.view.subviews[self.view.subviews.count-1].removeFromSuperview()
                        //remove loading screen
                })
            }
        }
        else {
            // SET OPPONENTS CUSTOM PIECE IF THEY HAVE ONE
            if let customSet = lastTurn["customSet"] as? String {
                defaults.setValue(customSet, forKey: "opponentCustomSet")
            }
            
            // CUSTOM PIECE FOR OPPONENT WHAT IS THIS?
            if let opponentsPiece = lastTurn["piece"] as? String {
                self.opponentsPiece = opponentsPiece
            }
            
            if let startGame = lastTurn["startGame"] as? String {
                
                setInitialPlayers(lastTurn["player"] as! String, receivedNumber: lastTurn["randomNumber"] as! Int)
                
            } else if let shift = lastTurn["shift"] as? String {
                self.performOpponentsShift(shift)
                isGameBoardLocked = false
                checkForWinner()
                
            } else {
                
                // MAKE OPPONENTS MOVE ON YOUR BOARD
                if let opponentSet = defaults.valueForKey("opponentCustomSet") as? String {
                    print("opponent has a custom set")
                }
                
                let index = lastTurn["field"] as! Int // field that was tapped
                
                let playerWhoMoved = lastTurn["player"] as! String
                
                let player = lastTurn["tac"] as! String // X or O
                
                let tappedField = self.fields[index] as TTTImageView
                
                tappedField.setOpponentPlayer(player)
                
                // LOCK THE BOARD FOR THE PERSON WHO JUST MOVED
                if playerWhoMoved == GKLocalPlayer.localPlayer().playerID {
                    isGameBoardLocked = true
                } else {
                    isGameBoardLocked = false
                }
                
                setupTabs("", playerID: "")
                
                if meterCounter > 7 {
                    bottomBubble.alpha = 1
                    // REMINDER TO SHIFT AFTER SKIPPING A SHIFT
                    bottomBubbleLabel.text = "スーパー担当"
                }
                
                SpringAnimation.springWithDelay(1, delay: 2.5, animations: { () -> Void in
                    self.bottomBubble.alpha = 0
                })
                
                self.bumpUpMeter()
                checkForWinner()
            }

        }
        
    }
    
    
    func sendMovesToOtherPlayer(field: Int, player: String, tacPiece: String) {
        
        // LOCK THE BOARD FOR THE PERSON WHO JUST MOVED
        if player == GKLocalPlayer.localPlayer().playerID {
            isGameBoardLocked = true
        } else {
            isGameBoardLocked = false
        }
        
        var messageDictionary = ["field": field, "player": player, "tac": tacPiece] as Dictionary<String,AnyObject>
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let customSet = defaults.valueForKey("customSet") as? String {
            messageDictionary["customSet"] = customSet
            
        }
        
        var moveData: NSData?
        do {
            moveData = try NSJSONSerialization.dataWithJSONObject(messageDictionary, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print(error)
        }
        
        do {
            try GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(moveData!, withDataMode: GKMatchSendDataMode.Reliable)
        } catch {
            print(error)
        }
    }
    
    
    // THIS SHOULD SET THE INITIAL PLAYERS POSITIONS
    func setInitialPlayers(receivedPlayer: String, receivedNumber: Int) {
        var playersArray = [Dictionary<String,AnyObject>]()
        
        playersArray.append(["player": GKLocalPlayer.localPlayer().playerID!, "number": localRandomNumber])
        playersArray.append(["player":receivedPlayer, "number":receivedNumber])
        
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: false)
        let newPlayersArray = (playersArray as NSArray).sortedArrayUsingDescriptors([sortDescriptor])
        
        orderOfPlayers = newPlayersArray
        
        print("PLAYERS IN THE GAME ARE (SET INITIAL PLAYERS): \(orderOfPlayers)")
        
        if orderOfPlayers[0].objectForKey("player") as! String == GKLocalPlayer.localPlayer().playerID! {
            print("YOU ARE PLAYER 1")
            self.currentPlayer = "x"
            player1 = GKLocalPlayer.localPlayer().playerID!
            player2 = orderOfPlayers[1].objectForKey("player") as? String
        } else {
            print("YOU ARE PLAYER 2")
            self.currentPlayer = "o"
            player1 = orderOfPlayers[0].objectForKey("player") as? String
            player2 = GKLocalPlayer.localPlayer().playerID!
        }
        
        // TAB SHIT MOTHER FUCKER
        xTabImageView.alpha = 1
        xImageView.image = UIImage(named: "tabX-pink")
        xTabActive = true
        
        oTabImageView.alpha = 1
        oImageView.image = UIImage(named: "tabO-blue")
        oTabActive = false
        
        // SLIDE OUT O
        UIView.animateWithDuration(1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.oTabImageView.transform = CGAffineTransformMakeTranslation(185, 0)
            self.oImageView.transform = CGAffineTransformMakeTranslation(185, 0)
            
            }, completion: nil)
        
        // CHECK IF PLAYER 1 TURN AND PLAYER 1 IS LOCAL DEVICE
        if player1 == GKLocalPlayer.localPlayer().playerID! {
            isGameBoardLocked = false
        } else {
            isGameBoardLocked = true
        }
    }
    
    // THIS IS THE VERY FIRST DATA SENT TO START THE GAME AND HELP SET PLAYERS POSITIONS
    func sendInitialData() {
        
        for field in self.fields {
            field.player = nil
            field.image = nil
            field.alpha = 1
        }
        
        let localPlayer = GKLocalPlayer.localPlayer().playerID!
        let messageDictionary = ["player": localPlayer, "randomNumber": localRandomNumber, "startGame": "yes"]
        let data = try! NSJSONSerialization.dataWithJSONObject(messageDictionary, options: NSJSONWritingOptions.PrettyPrinted)
        
        print("PLAYERS IN THE GAME ARE (SEND INITIAL DATA): \(self.match.players)")
        
        do {
            try GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable)
        }
        catch {
            print("error attempting rematch. other player may have gone home.")
        }
    }
    
    func fireArrowTimerUp() {
        self.arrowTimerRight = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("fireArrowTimerRight"), userInfo: nil, repeats: false)
        
        let upArrowOriginal = UIImage(named: "up")
        UIView.transitionWithView(self.upArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.upArrow.image = upArrowOriginal
            }, completion: nil)
        
        // TRANSITION RIGHT ARROW TO PINK
        let pinkRightArrow = UIImage(named: "right-pink")
        UIView.transitionWithView(self.rightArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.rightArrow.image = pinkRightArrow
            }, completion: nil)
    }
    
    func fireArrowTimerRight() {
        self.arrowTimerDown = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("fireArrowTimerDown"), userInfo: nil, repeats: false)
        let rightArrowOriginal = UIImage(named: "right")
        UIView.transitionWithView(self.rightArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.rightArrow.image = rightArrowOriginal
            }, completion: nil)
        
        // TRANSITION DOWN ARROW TO PINK
        let pinkDownArrow = UIImage(named: "down-pink")
        UIView.transitionWithView(self.downArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.downArrow.image = pinkDownArrow
            }, completion: nil)
    }
    
    func fireArrowTimerDown() {
        let downArrowOriginal = UIImage(named: "down")
        UIView.transitionWithView(self.downArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.downArrow.image = downArrowOriginal
            }, completion: nil)
        
        // TRANSITION LEFT ARROW TO PINK
        let pinkLeftArrow = UIImage(named: "left-pink")
        UIView.transitionWithView(self.leftArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.leftArrow.image = pinkLeftArrow
            }, completion: nil)
    }
    
    func blinkingArrows() {
        self.arrowTimerUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("fireArrowTimerUp"), userInfo: nil, repeats: false)
        
        let leftArrowOriginal = UIImage(named: "left")
        UIView.transitionWithView(self.leftArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.leftArrow.image = leftArrowOriginal
            }, completion: nil)
        
        // TRANSITION UP ARROW TO PINK
        let pinkUpArrow = UIImage(named: "up-pink")
        UIView.transitionWithView(self.upArrow, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.upArrow.image = pinkUpArrow
            }, completion: nil)
    }
    
    func resetArrows() {
        self.leftArrow.image = UIImage(named: "left")
        self.upArrow.image = UIImage(named: "up")
        self.rightArrow.image = UIImage(named: "right")
        self.downArrow.image = UIImage(named: "down")
    }
    
    func setupTabs(tacPiece: String, playerID: String) {
        
        if xTabActive == true {
            
            xTabActive = false
            oTabActive = true
            
            oTabImageView.alpha = 1
            
            // SLIDE IN O
            UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.oTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                self.oImageView.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: nil)
            
            
            // SLIDE OUT X
            UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.xTabImageView.transform = CGAffineTransformMakeTranslation(-180, 0)
                self.xImageView.transform = CGAffineTransformMakeTranslation(-185, 0)
                
                self.xTabImageView.alpha = 0
                
                }, completion: nil)
            
        } else if xTabActive == false {
            
            xTabActive = true
            oTabActive = false
            
            xTabImageView.alpha = 1
            
            // SLIDE IN X
            UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                
                self.xTabImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                self.xImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                
                }, completion: nil)
            
            // SLIDE OUT O
            UIView.animateWithDuration(1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.oTabImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                self.oImageView.transform = CGAffineTransformMakeTranslation(180, 0)
                
                self.oTabImageView.alpha = 0
                
                }, completion: nil)
            
        } else {
            
        }
        
    }
    
    func runAfterDelay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func makeComputerMove() {
        
        let brain = ComputerAIBrain()
        let directions = ["up","right","down","left"]
        let randomDirection = Int(arc4random_uniform(UInt32(directions.count)))
        
        // CHECK FOR WIN FIRST HERE
        if let win = brain.checkForTwoInARow("o", fields: fields) {
            self.performComputerAIPlay(win)
        }
        
        else if computerMeterCounter >= 7 {
            
            print("attempting to shift")
            let shiftUp = brain.computerAIShiftUp("x", fields: fields)
            let shiftRight = brain.computerAIShiftRight("x", fields: fields)
            let shiftDown = brain.computerAIShiftDown("x", fields: fields)
            let shiftLeft = brain.computerAIShiftLeft("x", fields: fields)
            
            if shiftUp.shouldShiftNow == true {
                self.performComputerAIShift("up")
            } else if shiftRight.shouldShiftNow == true {
                self.performComputerAIShift("right")
            } else if shiftDown.shouldShiftNow == true {
                self.performComputerAIShift("down")
            } else if shiftLeft.shouldShiftNow == true {
                self.performComputerAIShift("left")
            
            } else {
                
                if shiftUp.counter + shiftRight.counter + shiftDown.counter + shiftLeft.counter == 0 && brain.isBoardFull(fields) == false {
                    if let moveToMake = brain.playNormal(self.fields) {
                        self.performComputerAIPlay(moveToMake)
                    }
                }
    
                else if shiftUp.counter + shiftRight.counter + shiftDown.counter + shiftLeft.counter == 0 && brain.isBoardFull(fields) == true {
                    
                    self.performComputerAIShift(directions[randomDirection])
                
                }
    
                else if shiftUp.counter + shiftRight.counter + shiftDown.counter + shiftLeft.counter > 1 {
                    
                    // SHIFT RANDOM DIRECTION OF AVAILABLE 1'S
                    var availableDirections = [String]()
                    
                    if shiftUp.counter == 1 {
                        availableDirections.append("up")
                    } else if shiftRight.counter == 1 {
                        availableDirections.append("right")
                    } else if shiftDown.counter == 1 {
                        availableDirections.append("down")
                    } else if shiftLeft.counter == 1 {
                        availableDirections.append("left")
                    } else {
                        print("nothing available direction to shift?")
                    }
                    
                    let randomAvailableDirections = Int(arc4random_uniform(UInt32(availableDirections.count)))
                    
                    self.performComputerAIShift(availableDirections[randomAvailableDirections])
                    
                } else {
                    
                    if shiftUp.counter == 1 {
                        self.performComputerAIShift("up")
                    } else if shiftRight.counter == 1 {
                        self.performComputerAIShift("right")
                    } else if shiftDown.counter == 1 {
                        self.performComputerAIShift("down")
                    } else if shiftLeft.counter == 1 {
                        self.performComputerAIShift("left")
                    } else {
                        print("ERROR NO DIRECTION TO SHIFT")
                    }
                    
                }
                
            }
            
        // COMPUTER METER ISN'T FULL
        } else {
            if let moveToMake = brain.playNormal(self.fields) {
                self.performComputerAIPlay(moveToMake)
            } else {
                self.performComputerAIShift(directions[randomDirection])
            }
        }
        
    }
    
    func performComputerAIShift(direction: String) {
        delay(1, closure: { () -> () in
            self.performOpponentsShift(direction)
            self.updateBoardUI()
            self.computerMeterCounter = 1
            self.currentPlayer = "x"
            print("COMPUTER METER: \(self.computerMeterCounter)")
            self.isGameBoardLocked = false
        })
        
    }
    
    func performComputerAIPlay(moveToMake: Int) {
        delay(1, closure: { () -> () in
            if self.versusComputerGameOver == false {
                self.fields[moveToMake].setThePlayer("o", withPiece: self.ownPiece)
                self.setupTabs("", playerID: "")
                self.bumpUpMeter()
                print("COMPUTER METER: \(self.computerMeterCounter)")
                self.currentPlayer = "x"
                self.isGameBoardLocked = false
                self.checkForWinner()
            }
        })
    }
    
}
