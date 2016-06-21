/*
* Copyright (c) 2013-2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import GameKit
import Foundation

let PresentAuthenticationViewController = "PresentAuthenticationViewController"
let singleton = GameKitHelper()

protocol GameKitHelperDelegate {
  func matchStarted()
  func matchEnded()
  func matchCancelled()
  func matchReceivedData(match: GKMatch, data: NSData, fromPlayer player: String)
}

class GameKitHelper: NSObject, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate, GKLocalPlayerListener {
  var authenticationViewController: UIViewController?
  var lastError: NSError?
  var gameCenterEnabled: Bool
  
  var delegate: GameKitHelperDelegate?
  var multiplayerMatch: GKMatch?
  var presentingViewController: UIViewController?
  var multiplayerMatchStarted: Bool
  
    lazy var playerDetails: Dictionary<String, GKPlayer> = {
        return Dictionary<String, GKPlayer>()
        }()
    
  class var sharedInstance: GameKitHelper {
    return singleton
  }
    
    
  
  override init() {
    gameCenterEnabled = true
    multiplayerMatchStarted = false
    super.init()
  }
    
    func player(player: GKPlayer, didAcceptInvite invite: GKInvite) {
        
        print("SENDER: \(invite.sender)")
        print("HOSTED: \(invite.hosted)")
        print("PLAYER GROUP: \(invite.playerGroup)")
        
        //if let sender = invite.sender {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.inviteAccepted = true
            NSNotificationCenter.defaultCenter().postNotificationName("InviteAcceptedFromSender", object: nil)
        //}
        
        GKMatchmaker.sharedMatchmaker().matchForInvite(invite) { (match: GKMatch?, error: NSError?) -> Void in
            if match != nil {
                
                self.multiplayerMatch = match
                self.multiplayerMatch!.delegate = self
                
                if !self.multiplayerMatchStarted && self.multiplayerMatch?.expectedPlayerCount == 0 {
                    print("READY TO START: INVITE ACCEPTED")
                    self.multiplayerMatchStarted = true
                    self.delegate?.matchStarted()
                    //delegate?.matchReceivedData(match, data: data, fromPlayer: playerID)
                }
            } else {
                
            }
        }
    }
  
    func authenticateLocalPlayer () {
    
    //1
    let localPlayer = GKLocalPlayer.localPlayer()
    localPlayer.registerListener(self)
    localPlayer.authenticateHandler = {(viewController, error) in
        
      //2
      self.lastError = error
      
      if viewController != nil {
        //3
        self.authenticationViewController = viewController
        
        NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewController,
          object: self)
      } else if localPlayer.authenticated {
        //4
        self.gameCenterEnabled = true
      } else {
        //5
        self.gameCenterEnabled = false
      }
    }
  }
    
    
  func showGKGameCenterViewController(viewController: UIViewController!) {
    
    if !gameCenterEnabled {
      print("Local player is not authenticated")
      return
    }
    
    //1
    let gameCenterViewController = GKGameCenterViewController()
    
    //2
    gameCenterViewController.gameCenterDelegate = self
    
    //3
    gameCenterViewController.viewState = .Leaderboards
    
    //4
    viewController.presentViewController(gameCenterViewController,
      animated: true, completion: nil)
  }
    
  
  func findMatch(minPlayers: Int, maxPlayers: Int, presentingViewController viewController: UIViewController, delegate: GameKitHelperDelegate) {
    //1
    if !gameCenterEnabled {
      print("Local player is not authenticated")
      return
    }
    
    //2
    multiplayerMatchStarted = false
    multiplayerMatch = nil
    self.delegate = delegate
    presentingViewController = viewController
    
    //3
    let matchRequest = GKMatchRequest()
    matchRequest.minPlayers = minPlayers
    matchRequest.maxPlayers = maxPlayers
    
    //4
    let matchMakerViewController = GKMatchmakerViewController(matchRequest: matchRequest)
    matchMakerViewController!.matchmakerDelegate = self
    presentingViewController?.presentViewController(matchMakerViewController!, animated: true, completion:nil)
  }
    
    
    
    
    
  // MARK: GKGameCenterControllerDelegate methods
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
  }
    
  
  // MARK: GKMatchmakerViewControllerDelegate methods
  func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    print("matchmaking cancelled")
    delegate?.matchCancelled()
  }
  
  func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    print("Error creating a match: \(error.localizedDescription)")
    delegate?.matchEnded()
  }
  
  func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindMatch match: GKMatch!) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    multiplayerMatch = match
    multiplayerMatch!.delegate = self
    
    if !multiplayerMatchStarted && multiplayerMatch?.expectedPlayerCount == 0 {
      print("Ready to start the match")
      multiplayerMatchStarted = true
      delegate?.matchStarted()
    }
  }
    
    
    
    
  // MARK: GKMatchDelegate methods
  func match(match: GKMatch!, didReceiveData data: NSData!, fromPlayer playerID: String!) {
    if multiplayerMatch != match {
      return
    }
    delegate?.matchReceivedData(match, data: data, fromPlayer: playerID)
  }
  
 
    
    func match(match: GKMatch, didFailWithError error: NSError?) {
        if multiplayerMatch != match {
            return
        }
        multiplayerMatchStarted = false
        delegate?.matchEnded()
    }
    
    
    func match(match: GKMatch, player playerID: String, didChangeState state: GKPlayerConnectionState) {
        if multiplayerMatch != match {
            return
        }
        switch state {
            
        case .StateConnected:
            print("Player connected")
            if !multiplayerMatchStarted && multiplayerMatch?.expectedPlayerCount == 0 {
                print("Ready to start the match")
                multiplayerMatchStarted = true
                delegate?.matchStarted()
            }
            
        case .StateDisconnected:
            print("Player disconnected")
            multiplayerMatchStarted = false
            delegate?.matchEnded()
        case .StateUnknown:
            print("Initial player state")
        }
    }
    
}