//
//  TTTImageView.swift
//  Tac!
//
//  Created by Andrew Fashion on 7/4/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import UIKit

class TTTImageView: UIImageView {
    
    var player: String?
    var winningField: Bool = false
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let fileManager = NSFileManager.defaultManager()
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    override init(image: UIImage!) {
        super.init(image: image)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setThePlayer(thePlayer: String, withPiece : String) {
        self.player = thePlayer
        if self.player == "x" {
            if let customSet = defaults.valueForKey("customSet") as? String {
                
                checkCustomSet(customSet, player: thePlayer)
                //var path = self.paths.stringByAppendingPathComponent("tacX-\(customSet).png")
                //self.setImage(UIImage(contentsOfFile: path))
                
            } else {
                
                self.image = UIImage(named: "tacX-tacBundle0-set1")
            
            }
        } else if self.player == "o" {
            if let customSet = defaults.valueForKey("customSet") as? String {
            
                checkCustomSet(customSet, player: thePlayer)
                //var path = self.paths.stringByAppendingPathComponent("tacO-\(customSet).png")
                //self.setImage(UIImage(contentsOfFile: path))
            
            } else {
                
                self.image = UIImage(named: "tacO-tacBundle0-set1")
            
            }
        }
    }
    
    func setOpponentPlayer(thePlayer: String) {
        self.player = thePlayer
        if self.player == "x" {
            if let customSet = defaults.valueForKey("opponentCustomSet") as? String {
                
                checkCustomSet(customSet, player: thePlayer)
                
                //var path = self.paths.stringByAppendingPathComponent("tacX-\(customSet).png")
                //self.setImage(UIImage(contentsOfFile: path))
                
            } else {
                
                self.image = UIImage(named: "tacX-tacBundle0-set1")
                
            }
        } else if self.player == "o" {
            if let customSet = defaults.valueForKey("opponentCustomSet") as? String {
                
                checkCustomSet(customSet, player: thePlayer)
                //var path = self.paths.stringByAppendingPathComponent("tacO-\(customSet).png")
                //self.setImage(UIImage(contentsOfFile: path))
                
            } else {
            
                self.image = UIImage(named: "tacO-tacBundle0-set1")
                
            }
        }
    }
    
    
    func checkCustomSet(setName: String, player: String) {
        var tac = ""
        if player == "x" {
            tac = "tacX"
        } else {
            tac = "tacO"
        }
        
        if setName == "tacBundle0-set1" {
            
            self.image = UIImage(named: "\(tac)-tacBundle0-set1")
            
        } else if setName == "tacBundle0-set2" {
            
            self.image = UIImage(named: "\(tac)-tacBundle0-set2")
            
        } else if setName == "tacBundle0-set3" {
            
            self.image = UIImage(named: "\(tac)-tacBundle0-set3")
            
        } else {
            
            let path = NSURL(fileURLWithPath: self.paths).URLByAppendingPathComponent("\(tac)-\(setName).png")
            self.image = UIImage(data: NSData(contentsOfURL: path)!)
            
        }
    }
    
    
}
