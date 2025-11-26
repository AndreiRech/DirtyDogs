//
//  GameView.swift
//  DirtyDogs
//
//  Created by Júlia on 12/11/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @State var viewModel: GameViewModelProtocol
    
    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.gameScene, options: [.allowsTransparency])
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.endGame(with: .quit)
                    } label: {
                        Image("closeButton")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .padding()
                    }
                }
                Spacer()
            }
            
//            VStack {
//                Spacer()
//                
//                HStack(spacing: 16) {
//                    Button("Resetar grade") {
//                        viewModel.resetGrid()
//                    }
//                    .buttonStyle(.borderedProminent)
//                    
//                    Button("Spawnar bolinha") {
//                        viewModel.spawnItem(type: .ball)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.orange)
//                    
//                    Button("Enviar bomba") {
//                        viewModel.spawnItem(type: .bomb)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.red)
//                }
//                .padding(.bottom, 40)
//            }
        }
        .sheet(item: Binding(
            get: { viewModel.selectedIndex.map { SheetIndex(value: $0) } },
            set: { newVal in viewModel.selectedIndex = newVal?.value }
        )) { sheet in
            ScratchView(
                viewModel: ScratchViewModel(
                    layer: viewModel.gameScene.gridManager.blocks[sheet.value].layer,
                    isClear: true,
                    onComplete: {
                        viewModel.completeScratch(at: sheet.value)
                    },
                    onCancel: {
                        viewModel.cancelScratch()
                    }
                )
            )
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
    GameView(
        viewModel:
            GameViewModel(
                matchManager: MatchManager(),
                speechService: SpeechService()
            )
    )
}
