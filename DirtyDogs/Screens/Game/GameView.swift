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
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.availableItems) { item in
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.3))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .onTapGesture {
                                    viewModel.didUse(item: item)
                                }
                        }
                    }
                    .padding()
                }
                .frame(height: 70)
                
                HStack(spacing: 16) {
                    Button("Resetar grade") {
                        viewModel.resetGrid()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Bolinha") {
                        viewModel.spawnItem(type: .poop)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    Button("Bomba") {
                        viewModel.spawnItem(type: .bomb)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(item: Binding(
            get: { viewModel.selectedIndex.map { SheetIndex(value: $0) } },
            set: { newVal in viewModel.selectedIndex = newVal?.value }
        )) { sheet in
            ScratchView(
                viewModel: ScratchViewModel(
                    layer: viewModel.gameScene.gridManager.blocks[sheet.value].layer,
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
