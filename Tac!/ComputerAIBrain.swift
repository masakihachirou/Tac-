//
//  ComputerAIBrain.swift
//  Tac!
//
//  Created by Andrew Fashion on 10/18/15.
//  Copyright © 2015 Andrew Fashion. All rights reserved.
//

import UIKit

class ComputerAIBrain: NSObject {
    
    func playNormal(fields: [TTTImageView]) -> Int? {
        
        print("attempting to place a piece")
        
        var moveToMake: Int?
        
        // Make a win
        if let win = checkForTwoInARow("o", fields: fields) {
            return win
        }
            
        // Make a block
        else if let block = checkForTwoInARow("x", fields: fields) {
            return block
        }
        
        // Prevent weird fork
        else if let weirdFork = preventWeirdFork("x", fields: fields) {
            return weirdFork
        }
            
        // Check for available forks
        else if let fork = checkForFork("o", fields: fields) {
            return fork
        }
            
        // Check for center
        else if fields[4].player == nil {
            return 4
        }
        // Check for center and 8 empty fields
        else if fields[4].player == "x" && countEmptyFields(fields) == 8 {
            if let emptyCorner = playEmptyCorner(fields) {
                return emptyCorner
            }
        }
            
        // Play empty side
        else if let emptySide = playEmptySide(fields) {
            return emptySide
        }
            
        // Play empty corner
        else if let emptyCorner = playEmptyCorner(fields) {
            return emptyCorner
        }
            
        // Play opposite corner of opponent
        else if let opposite = playOppositeCornerOfOpponent("x", fields: fields) {
            return opposite
        }
            
        // Play empty side
        else if let emptySide = playEmptySide(fields) {
            return emptySide
        } else {
            print("no move to make?")
        }
        
        return moveToMake
        
    }
    
    func checkForTwoInARow(player: String, fields: [TTTImageView]) -> Int? {
        
        // CHECKING TOP HORIZONTAL ROW
        if fields[0].player == player && fields[1].player == player && fields[2].player == nil { // 110
            return 2
        }
        
        if fields[1].player == player && fields[2].player == player && fields[0].player == nil { // 011
            return 0
        }
        
        if fields[0].player == player && fields[2].player == player && fields[1].player == nil { // 101
            return 1
        }
        
        // CHECKING MIDDLE HORIZONTAL ROW
        if fields[3].player == player && fields[4].player == player && fields[5].player == nil { // 110
            return 5
        }
        
        if fields[4].player == player && fields[5].player == player && fields[3].player == nil { // 011
            return 3
        }
        
        if fields[3].player == player && fields[5].player == player && fields[4].player == nil { // 101
            return 4
        }
        
        // CHECKING BOTTOM HORIZONTAL ROW
        if fields[6].player == player && fields[7].player == player && fields[8].player == nil { // 110
            return 8
        }
        
        if fields[7].player == player && fields[8].player == player && fields[6].player == nil { // 011
            return 6
        }
        
        if fields[6].player == player && fields[8].player == player && fields[7].player == nil { // 101
            return 7
        }
        
        // CHECKING LEFT VERTICAL ROW
        if fields[0].player == player && fields[3].player == player && fields[6].player == nil { // 110
            return 6
        }
        
        if fields[3].player == player && fields[6].player == player && fields[0].player == nil { // 011
            return 0
        }
        
        if fields[0].player == player && fields[6].player == player && fields[3].player == nil { // 101
            return 3
        }
        
        // CHECKING MIDDLE VERTICAL ROW
        if fields[1].player == player && fields[4].player == player && fields[7].player == nil { // 110
            return 7
        }
        
        if fields[4].player == player && fields[7].player == player && fields[1].player == nil { // 011
            return 1
        }
        
        if fields[1].player == player && fields[7].player == player && fields[4].player == nil { // 101
            return 4
        }
        
        // CHECKING RIGHT VERTICAL ROW
        if fields[2].player == player && fields[5].player == player && fields[8].player == nil { // 110
            return 8
        }
        
        if fields[5].player == player && fields[8].player == player && fields[2].player == nil { // 011
            return 2
        }
        
        if fields[2].player == player && fields[8].player == player && fields[5].player == nil { // 101
            return 5
        }
        
        // CHECKING TOP LEFT TO BOTTOM RIGHT
        if fields[0].player == player && fields[8].player == nil && fields[4].player == player {
            return 8
        }
        
        if fields[0].player == nil && fields[8].player == player && fields[4].player == player {
            return 0
        }
        
        if fields[0].player == player && fields[8].player == player && fields[4].player == nil {
            return 4
        }
        
        // CHECK BOTTOM LEFT TO TOP RIGHT
        if fields[6].player == player && fields[2].player == nil && fields[4].player == player {
            return 2
        }
        
        if fields[6].player == nil && fields[2].player == player && fields[4].player == player {
            return 6
        }
        
        if fields[6].player == player && fields[2].player == player && fields[4].player == nil {
            return 4
        }
        
        
        
        return nil
    }
    
    func preventWeirdFork(player: String, fields: [TTTImageView]) -> Int? {
        
        var emptyFields = 0
        
        for field in fields {
            if field.player == nil {
                emptyFields++
            }
        }
        
        if fields[0].player == player && fields[7].player == player && emptyFields == 6 {
            return 3
        }
        
        if fields[2].player == player && fields[7].player == player && emptyFields == 6  {
            return 8
        }
        
        if fields[1].player == player && fields[8].player == player && emptyFields == 6  {
            return 2
        }
        
        if fields[0].player == player && fields[5].player == player && emptyFields == 6  {
            return 2
        }
        
        if fields[5].player == player && fields[6].player == player && emptyFields == 6  {
            return 8
        }
        
        if fields[2].player == player && fields[3].player == player && emptyFields == 6  {
            return 0
        }
        
        if fields[3].player == player && fields[8].player == player && emptyFields == 6  {
            return 7
        }
        
        return nil
    }
    
    func checkForFork(player: String, fields: [TTTImageView]) -> Int? {
        
        // CHECK TOP FORK
        if fields[0].player == player && fields[1].player == nil && fields[2].player == player && fields[3].player == nil &&  fields[6].player == nil {
            return 6
        }
        
        if fields[0].player == player && fields[1].player == nil && fields[2].player == player && fields[5].player == nil &&  fields[8].player == nil {
            return 8
        }
        
        // CHECK RIGHT FORK
        if fields[2].player == player && fields[5].player == nil && fields[8].player == player && fields[6].player == nil && fields[7].player == nil {
            return 6
        }
        
        if fields[2].player == player && fields[5].player == nil && fields[8].player == player && fields[0].player == nil && fields[1].player == nil {
            return 0
        }
        
        // CHECK BOTTOM FORK
        if fields[6].player == player && fields[7].player == nil && fields[8].player == player && fields[5].player == nil && fields[2].player == nil {
            return 2
        }
        
        if fields[6].player == player && fields[7].player == nil && fields[8].player == player && fields[3].player == nil && fields[0].player == nil {
            return 0
        }
        
        // CHECK LEFT FORK
        if fields[0].player == player && fields[3].player == nil && fields[6].player == player && fields[7].player == nil && fields[8].player == nil {
            return 8
        }
        
        if fields[0].player == player && fields[3].player == nil && fields[6].player == player && fields[1].player == nil && fields[2].player == nil {
            return 2
        }
        
        return nil
    }
    
    func playOppositeCornerOfOpponent(player: String, fields: [TTTImageView]) -> Int? {
        
        //CHECK TOP LEFT
        if fields[0].player == player && fields[2].player == nil {
            return 2
        }
        
        if fields[0].player == player && fields[6].player == nil {
            return 6
        }
        
        //CHECK TOP RIGHT
        if fields[2].player == player && fields[8].player == nil {
            return 8
        }
        
        if fields[2].player == player && fields[0].player == nil {
            return 0
        }
        
        //CHECK BOTTOM RIGHT
        if fields[8].player == player && fields[2].player == nil {
            return 2
        }
        
        if fields[8].player == player && fields[6].player == nil {
            return 6
        }
        
        //CHECK BOTTOM LEFT
        if fields[6].player == player && fields[0].player == nil {
            return 0
        }
        
        if fields[6].player == player && fields[8].player == nil {
            return 8
        }
        
        return nil
    }
    
    func playEmptyCorner(fields: [TTTImageView]) -> Int? {
        
        if fields[0].player == nil {
            return 0
        }
        
        if fields[2].player == nil {
            return 2
        }
        
        if fields[8].player == nil {
            return 8
        }
        
        if fields[6].player == nil {
            return 6
        }
        
        return nil
    }
    
    func playEmptySide(fields: [TTTImageView]) -> Int? {
        
        if fields[1].player == nil {
            return 1
        }
        
        if fields[3].player == nil {
            return 3
        }
        
        if fields[5].player == nil {
            return 5
        }
        
        if fields[7].player == nil {
            return 7
        }
        
        return nil
    }
    
    func isBoardFull(fields: [TTTImageView]) -> Bool? {
        if fields[0].player != nil &&
            fields[1].player != nil &&
            fields[2].player != nil &&
            fields[3].player != nil &&
            fields[4].player != nil &&
            fields[5].player != nil &&
            fields[6].player != nil &&
            fields[7].player != nil &&
            fields[8].player != nil {
                return true
        }
        return false
    }
    
    // CHECK FOR SHIFT UP
    func computerAIShiftUp(player: String, fields: [TTTImageView]) -> (shouldShiftNow: Bool, counter: Int) {
        
        var shiftUp: Bool?
        
        if fields[3].player == player && fields[6].player == player ||
            fields[4].player == player && fields[7].player == player ||
            fields[5].player == player && fields[8].player == player ||
            fields[3].player == player && fields[7].player == player ||
            fields[5].player == player && fields[7].player == player {
                return (false, 0)
        } else {
            shiftUp = true
        }
        
        if shiftUp == true {
            if fields[5].player == nil {
                if fields[3].player == player && fields[4].player == player {
                    return (false, 0)
                }
            }
            
            if fields[3].player == nil {
                if fields[4].player == player && fields[5].player == player {
                    return (false, 0)
                }
            }
            
            if fields[3].player == nil && fields[5].player == nil {  // NEW
                if  fields[4].player == player && fields[6].player == player ||  // NEW
                    fields[4].player == player && fields[8].player == player {  // NEW
                        return (false, 0)
                }
            }
            
            if fields[8].player == nil {
                if fields[6].player == player && fields[7].player == player {
                    return (false, 0)
                }
            }
            
            if fields[6].player == nil {
                if fields[7].player == player && fields[8].player == player {
                    return (false, 0)
                }
            }
            
            if fields[4].player == nil {
                if fields[3].player == player && fields[5].player == player {
                    return (false, 0)
                }
            }
            
            if fields[7].player == nil {
                if  fields[4].player == player && fields[5].player == player ||  // NEW
                    fields[3].player == player && fields[4].player == player ||  // NEW
                    fields[6].player == player && fields[8].player == player {
                        return (false, 0)
                }
            }
            if fields[1].player == nil {
                if fields[0].player == player && fields[3].player == player && fields[2].player == player {
                    return (false, 0)
                }
            }
            if fields[1].player == nil {
                if fields[0].player == player && fields[2].player == player && fields[5].player == player {
                    return (false, 0)
                }
            }
            
            if fields[3].player == "o" && fields[5].player == "o" && fields[7].player == "o" ||
                fields[3].player == "o" && fields[6].player == "o" && fields[7].player == "o" ||
                fields[5].player == "o" && fields[8].player == "o" && fields[7].player == "o" {
                    return (true, 1)
            } else {
                // CHECK FOR NEXT DIRECTION
                return (false, 1)
            }
            
        } else {
            return (false, 0)
        }
        
    }
    // CHECK FOR SHIFT RIGHT
    func computerAIShiftRight(player: String, fields: [TTTImageView]) -> (shouldShiftNow: Bool, counter: Int) {
        
        var shiftRight: Bool?
        
        if fields[0].player == player && fields[1].player == player ||
            fields[3].player == player && fields[4].player == player ||
            fields[6].player == player && fields[7].player == player ||
            fields[1].player == player && fields[3].player == player ||
            fields[3].player == player && fields[7].player == player {
                return (false, 0)
        } else {
            shiftRight = true
        }
        
        if shiftRight == true {
            if fields[7].player == nil {
                if  fields[1].player == player && fields[4].player == player {
                    return (false, 0)
                }
            }
            
            if fields[7].player == nil && fields[1].player == nil {  // NEW
                if  fields[4].player == player && fields[6].player == player ||  // NEW
                    fields[4].player == player && fields[0].player == player {  // NEW
                        return (false, 0)
                }
            }
            
            if fields[1].player == nil {
                if  fields[4].player == player && fields[7].player == player {
                    return (false, 0)
                }
            }
            
            if fields[0].player == nil {
                if fields[3].player == player && fields[6].player == player {
                    return (false, 0)
                }
            }
            
            if fields[6].player == nil {
                if fields[0].player == player && fields[3].player == player {
                    return (false, 0)
                }
            }
            
            if fields[3].player == nil {
                if  fields[4].player == player && fields[7].player == player ||  // NEW
                    fields[1].player == player && fields[4].player == player ||  // NEW
                    fields[0].player == player && fields[6].player == player {
                        return (false, 0)
                }
            }
            
            if fields[4].player == nil {
                if fields[1].player == player && fields[7].player == player {
                    return (false, 0)
                }
            }
            if fields[3].player == nil {
                if fields[0].player == player && fields[7].player == player && fields[6].player == player {
                    return (false, 0)
                }
            }
            if fields[3].player == nil {
                if fields[0].player == player && fields[1].player == player && fields[6].player == player {
                    return (false, 0)
                }
            }
            
            if fields[1].player == "o" && fields[3].player == "o" && fields[7].player == "o" ||
                fields[0].player == "o" && fields[1].player == "o" && fields[3].player == "o" ||
                fields[3].player == "o" && fields[6].player == "o" && fields[7].player == "o" {
                    return (true, 1)
            } else {
                // CHECK FOR NEXT DIRECTION
                return (false, 1)
            }
            
        } else {
            return (false, 0)
        }
        
    }
    // CHECK FOR SHIFT DOWN
    func computerAIShiftDown(player: String, fields: [TTTImageView]) -> (shouldShiftNow: Bool, counter: Int) {
        
        var shiftDown: Bool?
        
        if fields[0].player == player && fields[3].player == player ||
            fields[1].player == player && fields[4].player == player ||
            fields[2].player == player && fields[5].player == player ||
            fields[1].player == player && fields[3].player == player ||
            fields[1].player == player && fields[5].player == player {
                return (false, 0)
        } else {
            shiftDown = true
        }
        
        if shiftDown == true {
            if fields[3].player == nil {
                if fields[4].player == player && fields[5].player == player {
                    return (false, 0)
                }
            }
            
            if fields[3].player == nil && fields[5].player == nil {  // NEW
                if  fields[0].player == player && fields[4].player == player ||  // NEW
                    fields[2].player == player && fields[4].player == player {  // NEW
                        return (false, 0)
                }
            }
            
            if fields[5].player == nil {
                if fields[4].player == player && fields[3].player == player {
                    return (false, 0)
                }
            }
            
            if fields[2].player == nil {
                if fields[1].player == player && fields[0].player == player {
                    return (false, 0)
                }
            }
            
            if fields[0].player == nil {
                if fields[1].player == player && fields[2].player == player {
                    return (false, 0)
                }
            }
            
            if fields[1].player == nil {
                if  fields[4].player == player && fields[5].player == player ||  // NEW
                    fields[3].player == player && fields[4].player == player ||  // NEW
                    fields[0].player == player && fields[2].player == player {
                        return (false, 0)
                }
            }
            
            if fields[4].player == nil {
                if fields[3].player == player && fields[5].player == player {
                    return (false, 0)
                }
            }
            if fields[5].player == nil {
                if fields[1].player == player && fields[2].player == player && fields[8].player == player {
                    return (false, 0)
                }
            }
            if fields[5].player == nil {
                if fields[7].player == player && fields[8].player == player && fields[2].player == player {
                    return (false, 0)
                }
            }
            
            if fields[0].player == "o" && fields[3].player == "o" && fields[1].player == "o" ||
                fields[2].player == "o" && fields[5].player == "o" && fields[4].player == "o" ||
                fields[3].player == "o" && fields[1].player == "o" && fields[5].player == "o" {
                    return (true, 1)
            } else {
                // CHECK FOR NEXT DIRECTION
                return (false, 1)
            }
            
        } else {
            return (false, 0)
        }
        
    }
    // CHECK FOR SHIFT LEFT
    func computerAIShiftLeft(player: String, fields: [TTTImageView]) -> (shouldShiftNow: Bool, counter: Int) {
        
        var shiftLeft: Bool?
        
        if fields[1].player == player && fields[2].player == player ||
            fields[4].player == player && fields[5].player == player ||
            fields[7].player == player && fields[8].player == player ||
            fields[1].player == player && fields[5].player == player ||
            fields[7].player == player && fields[5].player == player {
                return (false, 0)
        } else {
            shiftLeft = true
        }
        
        if shiftLeft == true {
            if fields[1].player == nil {
                if fields[4].player == player && fields[7].player == player {
                    return (false, 0)
                }
            }
            
            if fields[1].player == nil && fields[7].player == nil {  // NEW
                if  fields[4].player == player && fields[2].player == player ||  // NEW
                    fields[4].player == player && fields[8].player == player {  // NEW
                        return (false, 0)
                }
            }
            
            if fields[7].player == nil {
                if fields[4].player == player && fields[1].player == player {
                    return (false, 0)
                }
            }
            
            if fields[2].player == nil {
                if fields[5].player == player && fields[8].player == player {
                    return (false, 0)
                }
            }
            
            if fields[8].player == nil {
                if fields[2].player == player && fields[5].player == player {
                    return (false, 0)
                }
            }
            
            if fields[5].player == nil {
                if  fields[1].player == player && fields[4].player == player ||  // NEW
                    fields[7].player == player && fields[4].player == player ||  // NEW
                    fields[2].player == player && fields[8].player == player {
                        return (false, 0)
                }
            }
            
            if fields[4].player == nil {
                if fields[1].player == player && fields[7].player == player {
                    return (false, 0)
                }
            }
            if fields[7].player == nil {
                if fields[5].player == player && fields[8].player == player && fields[6].player == player {
                    return (false, 0)
                }
            }
            if fields[7].player == nil {
                if fields[3].player == player && fields[6].player == player && fields[8].player == player {
                    return (false, 0)
                }
            }
            
            if fields[1].player == "o" && fields[2].player == "o" && fields[5].player == "o" ||
                fields[7].player == "o" && fields[5].player == "o" && fields[8].player == "o" ||
                fields[7].player == "o" && fields[1].player == "o" && fields[5].player == "o" {
                    return (true, 1)
            } else {
                // CHECK FOR NEXT DIRECTION
                return (false, 1)
            }
            
        } else {
            return (false, 0)
        }
        
    }
    
    func countEmptyFields(fields: [TTTImageView]) -> Int {
        var emptyFields = 0
        
        for field in fields {
            if field.player == nil {
                emptyFields++
            }
        }
        
        return emptyFields
    }
    
    func decideWhoPlaysFirst() {
        
    }
}
