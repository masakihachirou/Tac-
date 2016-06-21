////
////  MultiplayerNetworking.swift
////  Tac!
////
////  Created by Andrew Fashion on 8/3/15.
////  Copyright (c) 2015 Andrew Fashion. All rights reserved.
////
//
//
//import Foundation
//import GameKit
//
//protocol MultiplayerProtocol {
//    func matchEnded()
//    func matchCancelled()
//    func setCurrentPlayerIndex(index :Int)
//    func setPositionOfCar(index: Int, dx: Float, dy: Float, rotation: Float)
//    func gameOver(didLocalPlayerWin: Bool)
//    func setPlayerLabelsInOrder(playerAliases: [String])
//}
//
//class MultiplayerNetworking: NSObject, GameKitHelperDelegate {
//    var delegate: MultiplayerProtocol?
//    var noOfLaps: Int?
//    
//    var ourRandomNumber: UInt32
//    var gameState: GameState
//    var isPlayer1: Bool
//    var receivedAllRandomNumbers: Bool
//    var orderOfPlayers: [RandomNumberDetails]
//    var lapCompleteInformation: Dictionary<String, Int>
//    
//    
//    // SETS PLAYER ID AND GENERATES RANDOM NUMBER
//    class RandomNumberDetails: NSObject {
//        let playerId: String
//        let randomNumber: UInt32
//        
//        init(playerId: String, randomNumber: UInt32) {
//            self.playerId = playerId
//            self.randomNumber = randomNumber
//            super.init()
//        }
//        
//        override func isEqual(object: AnyObject?) -> Bool {
//            let randomNumberDetails = object as? RandomNumberDetails
//            return randomNumberDetails?.playerId == self.playerId
//        }
//    }
//    
//    
//    
//    override init() {
//        ourRandomNumber = arc4random()
//        gameState = GameState.WaitingForMatch
//        isPlayer1 = false
//        receivedAllRandomNumbers = false
//        
//        orderOfPlayers = [RandomNumberDetails]()
//        lapCompleteInformation = Dictionary<String, Int>()
//        orderOfPlayers.append(RandomNumberDetails(playerId: GKLocalPlayer.localPlayer().playerID, randomNumber: ourRandomNumber))
//        
//        super.init()
//    }
//    
//    
//    
//    enum GameState: Int {
//        case WaitingForMatch, WaitingForRandomNumber, WaitingForStart, Playing, Done
//    }
//    
//    enum MessageType: Int {
//        case RandomNumber, GameBegin, Move, LapComplete, GameOver
//    }
//    
//    struct Message {
//        let messageType: MessageType
//    }
//    
//    struct MessageRandomNumber {
//        let message: Message
//        let randomNumber: UInt32
//    }
//    
//    struct MessageGameBegin {
//        let message: Message
//    }
//    
//    struct MessageMove {
//        let message: Message
//        let dx: Float
//        let dy: Float
//        let rotate: Float
//    }
//    
//    struct MessageLapComplete {
//        let message: Message
//    }
//    
//    struct MessageGameOver {
//        let message: Message
//    }
//    
//    func retrieveAllPlayerAliases() {
//        var playerAliases = [String]()
//        
//        for playerDetail in orderOfPlayers {
//            let playerId = playerDetail.playerId
//            if let player = GameKitHelper.sharedInstance.playerDetails[playerId] {
//                playerAliases.append(player.alias)
//            }
//        }
//        delegate?.setPlayerLabelsInOrder(playerAliases)
//    }
//    
//    func isGameOver() -> Bool {
//        
//        for (playerId, noOfLaps) in lapCompleteInformation {
//            if noOfLaps == 0 {
//                return true
//            }
//        }
//        return false
//    }
//    
//    func hasLocalPlayerWon() -> Bool {
//        let winningIndex = indexForWinningPlayer()
//        
//        if let index = winningIndex {
//            let playerDetails = orderOfPlayers[index]
//            
//            if playerDetails.playerId == GKLocalPlayer.localPlayer().playerID {
//                return true
//            }
//        }
//        
//        return false
//    }
//    
//    func indexForWinningPlayer() -> Int? {
//        
//        var winningPlayerId: String?
//        
//        for (playerId, noOfLaps) in lapCompleteInformation {
//            if noOfLaps == 0 {
//                winningPlayerId = playerId
//                break
//            }
//        }
//        if let playerId = winningPlayerId {
//            return indexForPlayer(playerId)
//        }
//        return nil
//    }
//    
//    func indexForLocalPlayer() -> Int? {
//        return indexForPlayer(GKLocalPlayer.localPlayer().playerID)
//    }
//    
//    func indexForPlayer(playerId: String) -> Int? {
//        var idx: Int?
//        
//        for (index, playerDetail) in enumerate(orderOfPlayers) {
//            let pId = playerDetail.playerId
//            if pId == playerId {
//                idx = index
//                break
//            }
//        }
//        return idx
//    }
//    
//    func reduceNoOfLapsForPlayer(playerId: String) {
//        
//        if let laps = lapCompleteInformation[playerId] {
//            lapCompleteInformation[playerId] = laps - 1
//            print("Reduced laps:\(laps - 1)")
//        }
//    }
//    
//    func setupLapCompleteInformation() {
//        if let multiplayerMatch = GameKitHelper.sharedInstance.multiplayerMatch {
//            let playerIds = multiplayerMatch.players as! [String]
//            
//            for playerId in playerIds {
//                lapCompleteInformation[playerId] = noOfLaps
//            }
//            lapCompleteInformation[GKLocalPlayer.localPlayer().playerID] = noOfLaps
//        }
//    }
//    
//    func tryStartGame() {
//        if isPlayer1 && gameState == GameState.WaitingForStart {
//            gameState = GameState.Playing
//            sendBeginGame()
//            
//            //first player
//            delegate?.setCurrentPlayerIndex(0)
//        }
//    }
//    
//    func processReceivedRandomNumber(randomNumberDetails: RandomNumberDetails) {
//        //1
//        let mutableArray = NSMutableArray(array: orderOfPlayers)
//        mutableArray.addObject(randomNumberDetails)
//        
//        //2
//        let sortByRandomNumber = NSSortDescriptor(key: "randomNumber", ascending: false)
//        let sortDescriptors = [sortByRandomNumber]
//        mutableArray.sortUsingDescriptors(sortDescriptors)
//        
//        //3
//        orderOfPlayers = NSArray(array: mutableArray) as! [RandomNumberDetails]
//        
//        //4
//        if allRandomNumbersAreReceived() {
//            receivedAllRandomNumbers = true
//        }
//    }
//    
//    func allRandomNumbersAreReceived() -> Bool {
//        var receivedRandomNumbers = Set<UInt32>()
//        
//        for playerDetail in orderOfPlayers {
//            receivedRandomNumbers.insert(playerDetail.randomNumber)
//        }
//        
//        if let multiplayerMatch = GameKitHelper.sharedInstance.multiplayerMatch {
//            if receivedRandomNumbers.count == multiplayerMatch.playerIDs.count + 1 {
//                return true
//            }
//        }
//        return false
//    }
//    
//    func isLocalPlayerPlayer1() -> Bool {
//        let playerDetail = orderOfPlayers[0]
//        if playerDetail.playerId == GKLocalPlayer.localPlayer().playerID {
//            print("I'm player 1.. w00t :]")
//            return true
//        }
//        return false
//    }
//    
//    func sendRandomNumber() {
//        var message = MessageRandomNumber(message: Message(messageType: MessageType.RandomNumber), randomNumber: ourRandomNumber)
//        let data = NSData(bytes: &message, length: sizeof(MessageRandomNumber))
//        sendData(data)
//    }
//    
//    func sendMove(dx: Float, dy: Float, rotation: Float) {
//        var messageMove = MessageMove(message: Message(messageType: MessageType.Move), dx: dx, dy: dy, rotate: rotation)
//        let data = NSData(bytes: &messageMove, length: sizeof(MessageMove))
//        sendData(data)
//    }
//    
//    func sendData(data: NSData) {
//        var sendDataError: NSError?
//        let gameKitHelper = GameKitHelper.sharedInstance
//        
//        if let multiplayerMatch = gameKitHelper.multiplayerMatch {
//            let success = multiplayerMatch.sendDataToAllPlayers(data, withDataMode: .Reliable, error: &sendDataError)
//            
//            if !success {
//                if let error = sendDataError {
//                    print("Error sending data:\(error.localizedDescription)")
//                    matchEnded()
//                }
//            }
//        }
//    }
//    
//    func sendGameOverMessage() {
//        var gameOverMessage = MessageGameOver(message: Message(messageType: MessageType.GameOver))
//        let data = NSData(bytes: &gameOverMessage, length: sizeof(MessageGameOver))
//        sendData(data)
//    }
//    
//    func sendBeginGame() {
//        var message = MessageGameBegin(message: Message(messageType: MessageType.GameBegin))
//        let data = NSData(bytes: &message, length: sizeof(MessageGameBegin))
//        sendData(data)
//        retrieveAllPlayerAliases()
//    }
//    
//    func sendLapComplete() {
//        var lapCompleteMessage = MessageLapComplete(message: Message(messageType: MessageType.LapComplete))
//        let data = NSData(bytes: &lapCompleteMessage, length: sizeof(MessageLapComplete))
//        sendData(data)
//        
//        reduceNoOfLapsForPlayer(GKLocalPlayer.localPlayer().playerID)
//        
//        if isGameOver() && isPlayer1 {
//            sendGameOverMessage()
//            delegate?.gameOver(hasLocalPlayerWon())
//        }
//    }
//    
//    // MARK: GameKitHelperDelegate methods
//    func matchStarted() {
//        print("Match has started successfuly")
//        if receivedAllRandomNumbers {
//            gameState = GameState.WaitingForStart
//        } else {
//            gameState = GameState.WaitingForRandomNumber
//        }
//        sendRandomNumber()
//        tryStartGame()
//        setupLapCompleteInformation()
//    }
//    
//    func matchEnded() {
//        GameKitHelper.sharedInstance.multiplayerMatch?.disconnect()
//        delegate?.matchEnded()
//    }
//    
//    func matchCancelled() {
//        delegate?.matchCancelled()
//    }
//    
//    func matchReceivedData(match: GKMatch, data: NSData, fromPlayer player: String) {
//        //1
//        var message = UnsafePointer<Message>(data.bytes).memory
//        
//        if message.messageType == MessageType.RandomNumber {
//            let messageRandomNumber = UnsafePointer<MessageRandomNumber>(data.bytes).memory
//            
//            print("Received random number:\(messageRandomNumber.randomNumber)")
//            
//            var tie = false
//            if messageRandomNumber.randomNumber == ourRandomNumber {
//                //2
//                print("Tie")
//                tie = true
//                
//                var idx: Int?
//                
//                for (index, randomNumberDetails) in
//                    enumerate(orderOfPlayers) {
//                        
//                        if randomNumberDetails.randomNumber == ourRandomNumber {
//                            idx = index
//                            break
//                        }
//                }
//                
//                if let validIndex = idx {
//                    ourRandomNumber = arc4random()
//                    orderOfPlayers.removeAtIndex(validIndex)
//                    orderOfPlayers.append(RandomNumberDetails(playerId:
//                        GKLocalPlayer.localPlayer().playerID,randomNumber:ourRandomNumber))
//                }
//                
//                sendRandomNumber()
//            } else {
//                //3
//                processReceivedRandomNumber(RandomNumberDetails(playerId: player, randomNumber: messageRandomNumber.randomNumber))
//            }
//            
//            //4
//            if receivedAllRandomNumbers {
//                isPlayer1 = isLocalPlayerPlayer1()
//            }
//            
//            if !tie && receivedAllRandomNumbers {
//                //5
//                if gameState == GameState.WaitingForRandomNumber {
//                    gameState = GameState.WaitingForStart
//                }
//                tryStartGame()
//            }
//        } else if message.messageType == MessageType.GameBegin {
//            retrieveAllPlayerAliases()
//            gameState = GameState.Playing
//            if let localPlayerIndex = indexForLocalPlayer() {
//                delegate?.setCurrentPlayerIndex(localPlayerIndex)
//            }
//        } else if message.messageType == MessageType.Move {
//            let messageMove = UnsafePointer<MessageMove>(data.bytes).memory
//            
//            print("Dx: \(messageMove.dx) Dy: \(messageMove.dy) Rotation: \(messageMove.rotate)")
//            delegate?.setPositionOfCar(indexForPlayer(player)!, dx: messageMove.dx, dy: messageMove.dy, rotation: messageMove.rotate)
//        } else if message.messageType == MessageType.LapComplete {
//            reduceNoOfLapsForPlayer(player)
//            if isGameOver() && isPlayer1 {
//                sendGameOverMessage()
//                delegate?.gameOver(hasLocalPlayerWon())
//            }
//        } else if message.messageType == MessageType.GameOver {
//            delegate?.gameOver(hasLocalPlayerWon())
//        }
//    }
//}