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
    @State var speechService: SpeechServiceProtocol = SpeechService()
    
    var body: some View {
        ZStack {
            if matchManager.isGameOver {
                let viewModel = GameOverViewModel(matchManager: matchManager)
                GameOverView(viewModel: viewModel)
                
            } else if matchManager.gameState == .inGame {
                GameView(
                    matchManager: matchManager,
                    speechService: speechService
                )
                
            } else {
                let viewModel = MenuViewModel(
                    matchManager: matchManager,
                    hapticsService: hapticsService
                )
                MenuView(viewModel: viewModel)
            }
        }
        .onAppear {
            matchManager.authenticatePlayer()
        }
    }
}
