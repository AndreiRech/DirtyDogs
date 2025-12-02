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
    
    var screenTextLines: String {
        switch gameResult {
        case .victory:
            return "won"
        case .defeat:
            return "lost"
        case .quit:
            return "left"
        default:
            return "left"
        }
    }
    
    var boneImage: String? {
        switch gameResult {
        case .victory:
            return "boneFull"
        case .defeat:
            return "boneBroken"
        case .quit:
            return nil
        default:
            return nil
        }
    }
    
    func returnToMenu() {
        matchManager.returnToMenu()
    }
}
