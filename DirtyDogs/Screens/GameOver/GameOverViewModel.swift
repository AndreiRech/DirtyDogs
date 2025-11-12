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
    
    init(matchManager: MatchManager) {
        self.matchManager = matchManager
    }
    
    func returnToMenu() {
        matchManager.returnToMenu()
    }
}
