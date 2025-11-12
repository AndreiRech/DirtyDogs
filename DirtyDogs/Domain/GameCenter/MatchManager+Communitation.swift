//
//  MatchManager+Communitation.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation
import GameKit
import SpriteKit

extension MatchManager: GKMatchDelegate {
    // MARK: Gameplay Functions
    func startGame(newMatch: GKMatch) {
        self.match = newMatch
        match?.delegate = self
        otherPlayer = match?.players.first
        sendString("began:\(playerUUIDKey)")
    }
    
    func endGame() {
        inGame = false
        isGameOver = true
        sendString("gameOver")
    }
    
    // MARK: Communication Functions
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            let ballData = try JSONDecoder().decode(BallData.self, from: data)
            if ballData.type == "ball" {
                Task { @MainActor in
                    let spawnPoint = CGPoint(x: ballData.x, y: ballData.y)
                    let arrivingSide: EdgeSide = (ballData.side == .left ? .right : .left)
                    self.delegate?.spawnBall(at: spawnPoint, from: arrivingSide)
                }
                return
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
        
        let content = String(decoding: data, as: UTF8.self)
        if content.starts(with: "strData:") {
            let message = content.replacing("strData:", with: "")
            receivedString(message)
        }
    }
    
    func receivedString(_ message: String) {
        let messageSplit = message.split(separator: ":")
        guard let messagePrefix = messageSplit.first else { return }
        
        let parameter = String(messageSplit.last ?? "")
        
        switch messagePrefix {
        case "began":
            if parameter == playerUUIDKey {
                playerUUIDKey = UUID().uuidString
                sendString("began:\(playerUUIDKey)")
                break
            }
            inGame = true
            
        case "gameOver":
            inGame = false
            isGameOver = true
            
        default:
            break
        }
    }
    
    func sendString(_ message: String) {
        guard let enconded = "strData:\(message)".data(using: .utf8) else { return }
        sendData(enconded, mode: .reliable)
    }
    
    func sendData(_ data: Data, mode: GKMatch.SendDataMode) {
        do {
            try match?.sendData(toAllPlayers: data, with: mode)
        } catch {
            print("Erro ao enviar dados: \(error.localizedDescription)")
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        if state == .disconnected {
            endGame()
        }
    }
}
