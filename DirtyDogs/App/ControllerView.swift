//
//  ControllerView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI

struct ControllerView: View {
    @State var matchManager: MatchManager
    @State var hapticsService: HapticsServiceProtocol = HapticsService()
    @State var settingsService: SettingsServiceProtocol = SettingsService()
    @State var showMenu: Bool = false
   
    var body: some View {
        ZStack {
            if matchManager.isGameOver {
                GameOverView(viewModel: GameOverViewModel(matchManager: matchManager))
            } else if matchManager.gameState == .inGame {
                GameView(viewModel: GameViewModel(matchManager: matchManager, hapticsService: hapticsService))
            } else if showMenu {
                MenuView(viewModel: MenuViewModel(matchManager: matchManager, hapticsService: hapticsService, settingsService: settingsService))
            } else {
                SplashToPawsView(onFinished: {
                    showMenu = true
                })
            }
        }
        .onAppear {
            matchManager.authenticatePlayer()
        }
    }
}
