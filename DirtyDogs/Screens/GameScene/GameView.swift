//
//  GameView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI
import Speech
import SpriteKit

struct GameView: View {
    @State private var viewModel: GameViewModelProtocol

    init(matchManager: MatchManager, speechService: SpeechServiceProtocol) {
        _viewModel = State(
            initialValue: GameViewModel(
                matchManager: matchManager,
                speechService: speechService
            )
        )
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.physicsScene)
                .ignoresSafeArea()
            
            VolumeButtonService(matchManager: viewModel.matchManager)
                .frame(width: 0, height: 0)
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.endGame()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

#Preview {
    GameView(matchManager: MatchManager(), speechService: SpeechService())
}
