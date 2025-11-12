//
//  MatchManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation
import GameKit
import SpriteKit

@Observable
class MatchManager: NSObject {
    weak var delegate: MatchManagerDelegate?
    
    var authenticatingState: PlayerAuthStateEnum = .authenticating
    var inGame: Bool = false
    var isGameOver: Bool = false
    
    var match: GKMatch?
    var otherPlayer: GKPlayer?
    var localPlayer: GKLocalPlayer = GKLocalPlayer.local
    var playerUUIDKey: String = UUID().uuidString
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [self] vc, e in
            if let viewController = vc {
                rootViewController?.present(viewController, animated: true)
                return
            }
            
            if let error = e {
                authenticatingState = .error
                print(error.localizedDescription)
                return
            }
            
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    authenticatingState = .restricted
                } else {
                    authenticatingState = .authenticated
                }
            } else {
                authenticatingState = .notAuthenticated
            }
        }
    }
    
    func startMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        let matchmakingVC = GKMatchmakerViewController(matchRequest: request)
        matchmakingVC?.matchmakerDelegate = self
        
        if let matchmakingVC = matchmakingVC {
            rootViewController?.present(matchmakingVC, animated: true)
        }
    }
    
    func returnToMenu() {
        isGameOver = false
        inGame = false
        match?.disconnect()
        match = nil
        delegate = nil
    }
}
