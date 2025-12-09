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
            
            if viewModel.showQuitConfirmation {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .zIndex(19)
                    .onTapGesture {
                        viewModel.showQuitConfirmation = false
                    }
                
                GameAlert(
                    onCancel: {
                        viewModel.showQuitConfirmation = false
                    },
                    onConfirm: {
                        viewModel.endGame(with: .quit)
                    }
                )
                .zIndex(20)
            }
            
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
        }
        .onDisappear {
            viewModel.onDisappear()
            AudioService.shared.stopSimpleLoop(sound: "MatchSound.mp3")
        }
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
