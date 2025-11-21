//
//  GameOverViewModel.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

@Observable
class GameOverViewModel: GameOverViewModelProtocol {
    private var matchManager: MatchManager
    
    var gameResult: GameState {
        matchManager.gameState
    }
    
    init(matchManager: MatchManager) {
        self.matchManager = matchManager
    }
    
    var screenTextLines: [String] {
        switch gameResult {
        case .victory:
            return ["You", "Won!"]
        case .defeat:
            return ["You", "Lost!"]
        case .quit:
            return ["Your", "Enemy", "Left"]
        default:
            return ["\(gameResult)"]
        }
    }
    
    func returnToMenu() {
        matchManager.returnToMenu()
    }
}
