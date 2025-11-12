//
//  MenuViewModel.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

@Observable
class MenuViewModel: MenuViewModelProtocol {
    private var matchManager: MatchManager
    private var hapticsService: HapticsServiceProtocol
    
    init(matchManager: MatchManager, hapticsService: HapticsServiceProtocol) {
        self.matchManager = matchManager
        self.hapticsService = hapticsService
    }
    
    var authenticatingState: PlayerAuthStateEnum {
        matchManager.authenticatingState
    }
    
    var isPlayButtonDisabled: Bool {
        matchManager.authenticatingState != .authenticated || matchManager.inGame
    }
    
    func prepareHaptics() {
        hapticsService.prepareHaptics()
    }
    
    func playButtonTapped() {
        matchManager.startMatchmaking()
        hapticsService.complexSuccess()
    }
}
