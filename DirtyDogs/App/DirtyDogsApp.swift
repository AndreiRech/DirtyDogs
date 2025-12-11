//
//  DirtyDogsApp.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI

@main
struct DirtyDogsApp: App {
    @State private var matchManager = MatchManager()
    private let settingsService = SettingsService()
    private let hapticsService = HapticsService()
    
    init() {
        setupServices()
    }
    
    var body: some Scene {
        WindowGroup {
            MovingBackground()
            
//            ControllerView(
//                matchManager: matchManager,
//                hapticsService: hapticsService,
//                settingsService: settingsService
//            )
        }
    }
    
    private func setupServices() {
        hapticsService.isHapticsEnabled = settingsService.hapticsEnabled
        AudioService.shared.isSoundEnabled = settingsService.soundEnabled
        
        settingsService.onSoundChanged = { isEnabled in
            AudioService.shared.isSoundEnabled = isEnabled
        }
        
        settingsService.onHapticsChanged = { [weak hapticsService] isEnabled in
            hapticsService?.isHapticsEnabled = isEnabled
        }
    }
}
