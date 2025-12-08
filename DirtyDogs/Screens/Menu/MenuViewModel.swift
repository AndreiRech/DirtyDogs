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
    private var settingsService: SettingsServiceProtocol
    
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var showTutorial: Bool = false
    
    init(
        matchManager: MatchManager,
        hapticsService: HapticsServiceProtocol,
        settingsService: SettingsServiceProtocol
    ) {
        self.matchManager = matchManager
        self.hapticsService = hapticsService
        self.settingsService = settingsService
        
        self.soundEnabled = settingsService.soundEnabled
        self.hapticsEnabled = settingsService.hapticsEnabled
    }
    
    var authenticatingState: PlayerAuthStateEnum {
        matchManager.authenticatingState
    }
    
    var isPlayButtonDisabled: Bool {
        matchManager.authenticatingState != .authenticated || matchManager.gameState == .inGame
    }
    
    func playButtonTapped() {
        matchManager.startMatchmaking()
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        settingsService.soundEnabled = soundEnabled
    }
    
    func toggleHaptics() {
        hapticsEnabled.toggle()
        settingsService.hapticsEnabled = hapticsEnabled
    }
}
