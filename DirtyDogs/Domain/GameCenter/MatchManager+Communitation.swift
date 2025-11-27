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
    func startGame(newMatch: GKMatch) {
        self.match = newMatch
        match?.delegate = self
        otherPlayer = match?.players.first
        sendPacket(GamePacket(type: .began, uuid: playerUUIDKey))
    }
    
    func endGame(with event: PacketType) {
        sendPacket(GamePacket(type: event))
        
        switch event {
        case .victory:
            gameState = .victory
            isGameOver = true
        case .quit:
            returnToMenu()
        default :
            break
        }
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            let packet = try JSONDecoder().decode(GamePacket.self, from: data)
            
            switch packet.type {
                
            case .began:
                guard let uuid = packet.uuid else { return }
                
                if uuid == playerUUIDKey {
                    playerUUIDKey = UUID().uuidString
                    sendPacket(GamePacket(type: .began, uuid: playerUUIDKey))
                    break
                }
                gameState = .inGame
                
            case .victory:
                gameState = .defeat
                isGameOver = true
                
            case .quit:
                gameState = .quit
                isGameOver = true
                
            case .spawnPhysicsObject:
                guard let data = packet.physicsData else { return }
                Task { @MainActor in
                    self.delegate?.spawnObject(with: data)
                }
            }
            
        } catch {
            print("Erro ao decodificar GamePacket: \(error.localizedDescription)")
        }
    }
    
    func sendPacket(_ packet: GamePacket, mode: GKMatch.SendDataMode = .reliable) {
        do {
            let data = try JSONEncoder().encode(packet)
            try match?.sendData(toAllPlayers: data, with: mode)
        } catch {
            print("Erro ao codificar e enviar GamePacket (\(packet.type)): \(error.localizedDescription)")
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        if state == .disconnected || state == .unknown {
            gameState = .quit
            isGameOver = true
        }
    }
}
