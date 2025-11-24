//
//  GridView.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//
import SwiftUI
import SpriteKit

struct GridView: View {
    @State var viewModel: GridViewModelProtocol
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .ignoresSafeArea()
                    .zIndex(0)
                
                SpriteView(scene: viewModel.gameScene, options: [.allowsTransparency])
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    LazyVGrid(columns: viewModel.columns, spacing: 12) {
                        ForEach(Array(viewModel.blocks.enumerated()), id: \.offset) { index, block in
                            if !block.cleared {
                                Button {
                                    viewModel.selectedIndex = index
                                } label: {
                                    layerView(for: block.layer)
                                        .frame(height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white.opacity(0.2), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
                                    .frame(height: 110)
                                    .overlay(
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 26, weight: .semibold))
                                            .foregroundStyle(.green.opacity(0.8))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .zIndex(1)
                    
                    HStack(spacing: 16) {
                        Button("Resetar grade") {
                            viewModel.resetGrid()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Enviar bolinha") {
                            viewModel.spawnBall()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .zIndex(1)
                }
                .padding(.top, 40)
                
            }
            .sheet(item: Binding(
                get: { viewModel.selectedIndex.map { SheetIndex(value: $0) } },
                set: { newVal in viewModel.selectedIndex = newVal?.value }
            )) { sheet in
                ScratchView(
                    viewModel: ScratchViewModel(
                        layer: viewModel.blocks[sheet.value].layer,
                        onComplete: {
                            viewModel.completeScratch(at: sheet.value)
                        },
                        onCancel: {
                            viewModel.cancelScratch()
                        }
                    )
                )
            }
        }
    }
    
    @ViewBuilder
    private func layerView(for layer: Int) -> some View {
        switch layer {
        case 0: // Grama
            LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                .overlay(Image(.grass).resizable().scaledToFill())
            
        case 1: // Terra
            LinearGradient(colors: [.brown.opacity(0.8), .brown], startPoint: .top, endPoint: .bottom)
                .overlay(Image(.earth).resizable().scaledToFill())
            
        case 2: // Pedra
            LinearGradient(colors: [.gray.opacity(0.7), .gray.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                .overlay(Image(.rocks).resizable().scaledToFill())
            
        default:
            Color.clear
        }
    }
}
