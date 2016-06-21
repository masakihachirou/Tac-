
//
//  GameViewController.swift
//  Tac!
//
//  Created by Andrew Fashion on 7/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit
import GameKit

class GameViewController: UIViewController, UIAlertViewDelegate, GameKitHelperDelegate {

    @IBOutlet weak var playerLabel: UILabel!
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

    @IBOutlet var mainCircles: [UIImageView]!
    @IBOutlet weak var insideBoard: UIView!
    @IBOutlet weak var outsideBoard: UIView!
    @IBOutlet weak var meterView: MeterAnimationView!

    @IBOutlet weak var xTabImageView: UIImageView!
    @IBOutlet weak var xImageView: UIImageView!
    @IBOutlet weak var oTabImageView: UIImageView!
    @IBOutlet weak var oImageView: UIImageView!
    
    var localRandomNumber = Int(arc4random())
    var currentPlayer: String = "x"
    var player1: String?
    var player2: String?
    var isPlayer1Turn: Bool = true
    var isPlayer2Turn: Bool = true
    var player1Piece = "x"
    var player2Piece = "o"
    var orderOfPlayers = [AnyObject]()
    
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
    var xCounter = 0
    var oCounter = 0
    
    var isGameBoardLocked = true
    var shiftAvailable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        meterView.addStartAnimation()
        
        self.fields = [fieldOne, fieldTwo, fieldThree, fieldFour, fieldFive, fieldSix, fieldSeven, fieldEight, fieldNine]

        setupGameLogic()
        setupGameUI()
        
        // Create the Dynamic Animator
        animator = UIDynamicAnimator(referenceView: self.view)
        
        self.initialBoardFrame = self.insideBoard.frame
        
        // Launch MatchMaker to find 2 players
        GameKitHelper.sharedInstance.findMatch(2, maxPlayers: 2, presentingViewController: self, delegate: self)
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func setupGameLogic() {
        for var i = 0; i < 9; i++ {
            var circle = ["selection": "unchecked"]
            self.boardCircles.append(circle)
        }
    }
    
    func setupGameUI() {
        for field in fields {
            let tap = UITapGestureRecognizer(target: self, action: "fieldTapped:")
            tap.numberOfTapsRequired = 1
            field.addGestureRecognizer(tap)
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
                playerData.append(field.player!)
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
        
//        for field in fields {
//            if let imageData = field.image?.CGImage {
//            }
//            else {
//                field.player = nil
//            }
//        }
        
        movedUp = false
        movedDown = false
        movedLeft = false
        movedRight = false
    }
    
    func fieldTapped(sender: UITapGestureRecognizer) {
        
        var playerWhoMoved: String?
        
        // CHECK IF GAMEBOARD IS LOCKED
        if isGameBoardLocked == true {
            return
        }
        
        let tappedField = sender.view as! TTTImageView
        
        if tappedField.player == nil {
        
            tappedField.setThePlayer(currentPlayer)
            
            if meterCounter == 1 {
                meterView.addDash1Animation()
                meterCounter += 1
            } else if meterCounter == 2 {
                meterView.addDash2Animation()
                meterCounter += 1
            } else if meterCounter == 3 {
                meterView.addDash3Animation()
                meterCounter += 1
            } else if meterCounter == 4 {
                meterView.addDash4Animation()
                meterCounter += 1
            } else if meterCounter == 5 {
                meterView.addDash5Animation()
                meterCounter += 1
            } else if meterCounter == 6 {
                meterView.addDash6Animation()
                meterCounter += 1
                shiftAvailable = true
            } else {
                //meterView.addPowerDownAnimation()
                //meterCounter = 1
            }

            self.boardCircles[tappedField.tag]["selection"] = currentPlayer
            
            if currentPlayer == "x" {
                
                //currentPlayer = "o"
                xCounter += 1
                
                println("X: \(xCounter)")
                println("O: \(oCounter)")
                
                oTabImageView.image = UIImage(named: "tabRightActive")
                oImageView.image = UIImage(named: "tabO-blue")
                
                xTabImageView.image = UIImage(named: "tabDefault")
                xImageView.image = UIImage(named: "tabX")
                
            } else {
                
                //currentPlayer = "x"
                oCounter += 1
                
                println("X: \(xCounter)")
                println("O: \(oCounter)")
                
                xTabImageView.image = UIImage(named: "tabActive")
                xImageView.image = UIImage(named: "tabX-pink")
                
                oTabImageView.image = UIImage(named: "tabRightDefault")
                oImageView.image = UIImage(named: "tabO")
                
            }
            
            self.playerLabel.text = "Their Turn"
            
            // CHECK WHO IS MOVING
            if player1 == GKLocalPlayer.localPlayer().playerID {
                playerWhoMoved = player1
                sendMovesToOtherPlayer(tappedField.tag, player: playerWhoMoved!, tacPiece: "x")
            } else if player2 == GKLocalPlayer.localPlayer().playerID {
                playerWhoMoved = player2
                sendMovesToOtherPlayer(tappedField.tag, player: playerWhoMoved!, tacPiece: "o")
            }
            
            checkForWinner()
        }
        
        
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if shiftAvailable {
            if isGameBoardLocked == true {
                return
            }
            
            if snapBehaviour != nil {
                animator.removeBehavior(snapBehaviour)
            }
            
            if sender.state == UIGestureRecognizerState.Began {
                spring(1, { () -> Void in
                    for circle in self.mainCircles {
                        circle.alpha = 0.2
                    }
                })
            }
            
            self.view.bringSubviewToFront(sender.view!)
            var translation = sender.translationInView(self.view!)
            
            let threshold : CGFloat = 5.0
            var movingLeftRight = true
            
            if abs(translation.x) >= threshold || abs(translation.y) >= threshold {
                
                if abs(translation.y) >= abs(translation.x) {
                    movingLeftRight = false
                }
                
                if movingLeftRight && !stillDraggingUpDown {
                    
                    stillDraggingLeftRight = true
                    sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, outsideBoard.center.y)
                    
                    if abs(abs(sender.view!.center.x) - abs(outsideBoard.center.x)) <= 40 {
                        destination = CGPointMake(self.view.center.x, self.view.center.y)
                    } else if sender.view!.center.x >= outsideBoard.center.x {
                        destination = CGPointMake(self.view.center.x + 84, self.view.center.y)
                        movedRight = true
                    } else {
                        destination = CGPointMake(self.view.center.x - 84, self.view.center.y)
                        movedLeft = true
                    }
                    
                } else if !stillDraggingLeftRight { //up/down
                    
                    stillDraggingUpDown = true
                    sender.view!.center = CGPointMake(outsideBoard.center.x, sender.view!.center.y + translation.y)
                    
                    if abs(abs(sender.view!.center.y) - abs(outsideBoard.center.y)) <= 40 {
                        destination = CGPointMake(self.view.center.x, self.view.center.y)
                    } else if sender.view!.center.y >= outsideBoard.center.y {
                        destination = CGPointMake(self.view.center.x, self.view.center.y + 86)
                        movedDown = true
                    } else {
                        destination = CGPointMake(self.view.center.x, self.view.center.y - 86)
                        movedUp = true
                    }
                }
                
                sender.setTranslation(CGPointZero, inView: self.view!)
            }
            
            if sender.state == UIGestureRecognizerState.Ended {
                
                stillDraggingLeftRight = false
                stillDraggingUpDown = false
                
                spring(1, { () -> Void in
                    for circle in self.mainCircles {
                        circle.alpha = 1
                    }
                })
                var playerWhoMoved: String!
                // CHECK WHO IS MOVING
                if player1 == GKLocalPlayer.localPlayer().playerID {
                    playerWhoMoved = player1
                } else if player2 == GKLocalPlayer.localPlayer().playerID {
                    playerWhoMoved = player2
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
                
                let moveData = NSJSONSerialization.dataWithJSONObject(shiftDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                
                GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(moveData, withDataMode: GKMatchSendDataMode.Reliable, error: nil)
                
                isGameBoardLocked = true
                
                shiftAvailable = false

                self.playerLabel.text = "Their Turn"
                
                updateBoardUI()
                
                meterView.addPowerDownAnimation()
                meterCounter = 1
                if currentPlayer == "x" {
                    xCounter = 0
                    println("X: \(xCounter)")
                    println("O: \(oCounter)")
                } else {
                    oCounter = 0
                    println("X: \(xCounter)")
                    println("O: \(oCounter)")
                }
            }
        }
    }
    
    func checkForWinner() {
        
        // CHECKING FIRST ROW
        if fieldOne.player == "x" && fieldTwo.player == "x" && fieldThree.player == "x" {
            winner = "x"
        }
        
        if fieldOne.player == "o" && fieldTwo.player == "o" && fieldThree.player == "o" {
            winner = "o"
        }
        
        // CHECKING SECOND ROW
        if fieldFour.player == "x" && fieldFive.player == "x" && fieldSix.player == "x" {
            winner = "x"
        }
        
        if fieldFour.player == "o" && fieldFive.player == "o" && fieldSix.player == "o" {
            winner = "o"
        }
        
        // CHECKING THIRD ROW
        if fieldSeven.player == "x" && fieldEight.player == "x" && fieldNine.player == "x" {
            winner = "x"
        }
        
        if fieldSeven.player == "o" && fieldEight.player == "o" && fieldNine.player == "o" {
            winner = "o"
        }
        
        // CHECKING LEFT ROW
        if fieldOne.player == "x" && fieldFour.player == "x" && fieldSeven.player == "x" {
            winner = "x"
        }
        
        if fieldOne.player == "o" && fieldFour.player == "o" && fieldSeven.player == "o" {
            winner = "o"
        }
        
        // CHECKING MIDDLE ROW
        if fieldTwo.player == "x" && fieldFive.player == "x" && fieldEight.player == "x" {
            winner = "x"
        }
        
        if fieldTwo.player == "o" && fieldFive.player == "o" && fieldEight.player == "o" {
            winner = "o"
        }
        
        // CHECKING RIGHT ROW
        if fieldThree.player == "x" && fieldSix.player == "x" && fieldNine.player == "x" {
            winner = "x"
        }
        
        if fieldThree.player == "o" && fieldSix.player == "o" && fieldNine.player == "o" {
            winner = "o"
        }
        
        // CHECKING DIAGONAL TOP LEFT TO BOTTOM RIGHT
        if fieldOne.player == "x" && fieldFive.player == "x" && fieldNine.player == "x" {
            winner = "x"
        }
        
        if fieldOne.player == "o" && fieldFive.player == "o" && fieldNine.player == "o" {
            winner = "o"
        }
        
        // CHECKING DIAGONAL TOP RIGHT TO BOTTOM LEFT
        if fieldThree.player == "x" && fieldFive.player == "x" && fieldSeven.player == "x" {
            winner = "x"
        }
        
        if fieldThree.player == "o" && fieldFive.player == "o" && fieldSeven.player == "o" {
            winner = "o"
        }
        
        if let winner = winner {
            println(winner + " won")
            
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
            
//            fieldOne.image = nil
//            fieldTwo.image = nil
//            fieldThree.image = nil
//            fieldFour.image = nil
//            fieldFive.image = nil
//            fieldSix.image = nil
//            fieldSeven.image = nil
//            fieldEight.image = nil
//            fieldNine.image = nil
            
            GameKitHelper.sharedInstance.multiplayerMatch?.disconnect()
            
            spring(2, { () -> Void in
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("GameOverVC") as! GameOverViewController
                self.presentViewController(vc, animated: true, completion: nil)
            })
            
            
        }
        
    }
    
    func rematch() {
        self.match.rematchWithCompletionHandler { (match : GKMatch!, error: NSError!) -> Void in
            println("rematch accepted")
        }
    }

    func showWinAlert() {
        let alert = UIAlertView(title: "You Won!", message: "Congratulations.", delegate: self, cancelButtonTitle: "Ok")
    }
    
    func matchStarted() {
        println("match started")
        self.match = GameKitHelper.sharedInstance.multiplayerMatch
        sendInitialData()
    }
    
    func matchEnded() {
        println(" match ended")
        rematch()
    }
    
    func performOpponentsShift(shift : String) {
        
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
    }
    
    func bumpUpMeter() {
        if meterCounter == 1 {
            meterView.addDash1Animation()
            meterCounter += 1
        } else if meterCounter == 2 {
            meterView.addDash2Animation()
            meterCounter += 1
        } else if meterCounter == 3 {
            meterView.addDash3Animation()
            meterCounter += 1
        } else if meterCounter == 4 {
            meterView.addDash4Animation()
            meterCounter += 1
        } else if meterCounter == 5 {
            meterView.addDash5Animation()
            meterCounter += 1
        } else if meterCounter == 6 {
            meterView.addDash6Animation()
            meterCounter += 1
            
            shiftAvailable = true
        } else {
            //meterView.addPowerDownAnimation()
            //meterCounter = 1
        }
    }
    
    func matchReceivedData(match: GKMatch, data: NSData, fromPlayer player: String) {
        var error : NSError?
        let lastTurn = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as! Dictionary<String, AnyObject>
        
        if let val: AnyObject = lastTurn["startGame"] {
            
            setInitialPlayers(lastTurn["player"] as! String, receivedNumber: lastTurn["randomNumber"] as! Int)
            
        }
        else if let shift = lastTurn["shift"] as? String {
            self.performOpponentsShift(shift)
            
            self.playerLabel.text = "Your Turn"
            
            isGameBoardLocked = false
        }
        else {
            
            let index = lastTurn["field"] as! Int
            let playerWhoMoved = lastTurn["player"] as! String
            let player = lastTurn["tac"] as! String
            let tappedField = self.fields[index] as TTTImageView
            tappedField.setThePlayer(player)
            self.boardCircles[tappedField.tag]["selection"] = player
            
            // LOCK THE BOARD FOR THE PERSON WHO JUST MOVED
            if playerWhoMoved == GKLocalPlayer.localPlayer().playerID {
                isGameBoardLocked = true
            } else {
                isGameBoardLocked = false
            }
            
            if player == "x" {
                
                //currentPlayer = "o"
                            xCounter += 1
                
                            println("X: \(xCounter)")
                            println("O: \(oCounter)")
                //
                oTabImageView.image = UIImage(named: "tabRightActive")
                oImageView.image = UIImage(named: "tabO-blue")
                
                xTabImageView.image = UIImage(named: "tabDefault")
                xImageView.image = UIImage(named: "tabX")
                
            } else {
                
                //currentPlayer = "x"
                            oCounter += 1
                
                            println("X: \(xCounter)")
                            println("O: \(oCounter)")
                //
                xTabImageView.image = UIImage(named: "tabActive")
                xImageView.image = UIImage(named: "tabX-pink")
                
                oTabImageView.image = UIImage(named: "tabRightDefault")
                oImageView.image = UIImage(named: "tabO")
                
            }
            
            self.playerLabel.text = "Your Turn"
            
            self.bumpUpMeter()
        }
        
        checkForWinner()
    }
    
    
    func sendMovesToOtherPlayer(field: Int, player: String, tacPiece: String) {
        
        // LOCK THE BOARD FOR THE PERSON WHO JUST MOVED
        if player == GKLocalPlayer.localPlayer().playerID {
            isGameBoardLocked = true
        } else {
            isGameBoardLocked = false
        }
        
        let messageDictionary = ["field": field, "player": player, "tac": tacPiece]
        let moveData = NSJSONSerialization.dataWithJSONObject(messageDictionary, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(moveData, withDataMode: GKMatchSendDataMode.Reliable, error: nil)
    }
    
    
    // THIS SHOULD SET THE INITIAL PLAYERS POSITIONS
    func setInitialPlayers(receivedPlayer: String, receivedNumber: Int) {
        var playersArray = [Dictionary<String,AnyObject>]()
        
        playersArray.append(["player":GKLocalPlayer.localPlayer().playerID, "number":localRandomNumber])
        playersArray.append(["player":receivedPlayer, "number":receivedNumber])
        
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: false)
        var newPlayersArray = (playersArray as NSArray).sortedArrayUsingDescriptors([sortDescriptor])
        
        orderOfPlayers = newPlayersArray
        
        println(orderOfPlayers)
        
        if orderOfPlayers[0].objectForKey("player") as! String == GKLocalPlayer.localPlayer().playerID! {
            println("yes you are player 1")
            self.currentPlayer = "x"
            player1 = GKLocalPlayer.localPlayer().playerID!
            player2 = orderOfPlayers[1].objectForKey("player") as? String
            
            self.playerLabel.text = "Your Turn"
        } else {
            self.currentPlayer = "o"
            
            self.playerLabel.text = "Their Turn"

            player1 = orderOfPlayers[0].objectForKey("player") as? String
            player2 = GKLocalPlayer.localPlayer().playerID!
        }
        
        xTabImageView.image = UIImage(named: "tabActive")
        xImageView.image = UIImage(named: "tabX-pink")
        
        oTabImageView.image = UIImage(named: "tabRightDefault")
        oImageView.image = UIImage(named: "tabO")
        
        // CHECK IF PLAYER 1 TURN AND PLAYER 1 IS LOCAL DEVICE
        if player1 == GKLocalPlayer.localPlayer().playerID! {
            isGameBoardLocked = false
        } else {
            isGameBoardLocked = true
        }
    }
    
    // THIS IS THE VERY FIRST DATA SENT TO START THE GAME AND HELP SET PLAYERS POSITIONS
    func sendInitialData() {
        var localPlayer = GKLocalPlayer.localPlayer().playerID
        let messageDictionary = ["player": localPlayer, "randomNumber": localRandomNumber, "startGame": "yes"]
        let data = NSJSONSerialization.dataWithJSONObject(messageDictionary, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        GameKitHelper.sharedInstance.multiplayerMatch?.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable, error: nil)
    }
    
    
    
}
