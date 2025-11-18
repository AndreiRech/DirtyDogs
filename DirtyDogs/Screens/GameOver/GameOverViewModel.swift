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
    
    func getScreenText() -> String {
        switch gameResult {
        case .victory:
            "You Won :)"
        case .defeat:
            "You Lost :("
        case .quit:
            "Your opponent left."
        default:
            "\(gameResult)"
        }
    }
    
    func returnToMenu() {
        matchManager.returnToMenu()
    }
}
