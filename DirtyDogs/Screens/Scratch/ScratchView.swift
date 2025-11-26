//
//  ScratchView.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

struct ScratchView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: ScratchViewModelProtocol
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            ZStack {
                // Fundo depende da camada
                layerBackground(for: viewModel.layer)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Ícone da camada no centro com leve animação
                VStack {
                    Image(systemName: viewModel.layerSymbol(for: viewModel.layer))
                        .font(.system(size: 120))
                        .foregroundStyle(.white.opacity(0.8))
                        .shadow(radius: 10)
                        .scaleEffect(1 + viewModel.revealRatio * 0.3)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.revealRatio)
                }
                .opacity(0.25 + viewModel.revealRatio * 0.4)
                
                // Máscara "sujeira"
                Canvas { context, _ in
                    for (i, point) in viewModel.gridPoints.enumerated() {
                        if !viewModel.clearedCells.contains(i) {
                            let rect = CGRect(
                                x: point.x - viewModel.brushRadius,
                                y: point.y - viewModel.brushRadius,
                                width: viewModel.brushRadius * 2,
                                height: viewModel.brushRadius * 2
                            )
                            context.fill(Path(ellipseIn: rect), with: .color(viewModel.layerMaskColor(for: viewModel.layer)))
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let p = value.location
                            let r2 = viewModel.brushRadius * viewModel.brushRadius
                            var changed = false
                            for (i, point) in viewModel.gridPoints.enumerated() {
                                if !viewModel.clearedCells.contains(i) {
                                    let dx = point.x - p.x
                                    let dy = point.y - p.y
                                    if (dx*dx + dy*dy) <= r2 {
                                        viewModel.clearedCells.insert(i)
                                        changed = true
                                    }
                                }
                            }
                            if changed { viewModel.updateRevealRatio() }
                        }
                )
                
                // HUD
                VStack {
                    HStack {
                        Button {
                            viewModel.onCancel()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .padding(10)
                                .background(.thinMaterial, in: Circle())
                        }
                        Spacer()
                        Text("Limpeza: \(Int(viewModel.revealRatio * 100))%")
                            .font(.headline.monospacedDigit())
                            .padding(10)
                            .background(.thinMaterial, in: Capsule())
                        Spacer().frame(width: 40)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    Text("Raspe para revelar a próxima camada")
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 20)
                }
            }
            .background(Color.black.opacity(0.85).ignoresSafeArea())
            .onAppear { viewModel.setupGrid(in: size) }
            .onChange(of: geo.size) { oldValue, newValue in
                viewModel.setupGrid(in: newValue)
            }
            .onChange(of: viewModel.clearedCells) {
                if viewModel.revealRatio >= viewModel.targetRevealRatio {
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.25))
                        viewModel.onComplete()
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Fundo conforme a camada
    @ViewBuilder
    private func layerBackground(for layer: Int) -> some View {
        switch layer {
        case 0:
            LinearGradient(colors: [.green.opacity(0.4), .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        case 1:
            LinearGradient(colors: [.brown.opacity(0.6), .brown.opacity(0.9)], startPoint: .top, endPoint: .bottom)
        case 2:
            LinearGradient(colors: [.gray.opacity(0.7), .gray.opacity(0.9)], startPoint: .top, endPoint: .bottom)
        default:
            RadialGradient(colors: [.yellow, .orange], center: .center, startRadius: 10, endRadius: 500)
        }
    }
}
