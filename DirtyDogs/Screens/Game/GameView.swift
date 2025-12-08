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
                
            
            if !viewModel.isOverAll {
                VStack {
                    Spacer()
                    InventoryView(bonesFound: viewModel.bonesFound, availableItems: viewModel.availableItems, slotThatShouldAnimate: viewModel.slotThatShouldAnimate, onItemTap: { item in
                        viewModel.didUse(item: item)
                    })
                    .offset(y: -55)
                }
                .zIndex(1)
                
                if let index = viewModel.selectedIndex {
                    let block = viewModel.gameScene.gridManager.blocks[index]
                    let rewardForThisLayer: Reward = block.rewards[block.layer] ?? .none
                    
                    ScratchView(
                        viewModel: ScratchViewModel(
                            layer: viewModel.gameScene.gridManager.blocks[index].layer,
                            isClear: index % 2 == 0,
                            reward: rewardForThisLayer,
                            onComplete: {
                                viewModel.completeScratch(at: index)
                            },
                            playHaptics: {
                                switch rewardForThisLayer {
                                case .bomb, .tint, .seed:
                                    viewModel.playHaptics(sound: .itemFound)
                                case .bone:
                                    viewModel.playHaptics(sound: .success)
                                default:
                                    break
                                }
                            }
                        )
                    )
                    .id("\(index)-\(block.layer)")
                    .zIndex(2)
                    .transition(.opacity)
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            if let _ = viewModel.selectedIndex {
                                viewModel.cancelScratch()
                            } else {
                                viewModel.showQuitConfirmation = true
                            }
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
                .zIndex(3)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedIndex)
        .onAppear {
            AudioService.shared.playLoopSimple(sound: "MatchSound.mp3", volume: 0.1)
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
            AudioService.shared.stopSimpleLoop(sound: "MatchSound.mp3")
        }
        .alert("Leave the game?", isPresented: $viewModel.showQuitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) { viewModel.endGame(with: .quit) }
        } message: { Text("Are you sure that you want to leave?") }
    }
}

#Preview {
    GameView(
        viewModel:
            GameViewModel(
                matchManager: MatchManager(),
                hapticsService: HapticsService()
            )
    )
}
