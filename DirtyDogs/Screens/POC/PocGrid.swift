//
//  PocGrid.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 12/11/25.
//

import SwiftUI

// MARK: - Modelo do bloco com camadas
struct GridBlock: Identifiable, Hashable {
    let id = UUID()
    var layer: Int = 0 // 0=grama, 1=terra, 2=pedra, 3=limpo
    var cleared: Bool { layer >= 3 }
}

// MARK: - Tela principal com grade 3x3
struct ScratchGridGameView: View {
    @State private var blocks: [GridBlock] = Array(repeating: GridBlock(), count: 9)
    @State private var selectedIndex: Int? = nil
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Raspadinha das Camadas")
                    .font(.title2.bold())
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                        if !block.cleared {
                            Button {
                                selectedIndex = index
                            } label: {
                                layerView(for: block.layer)
                                    .frame(height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.2), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: blocks)
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
                
                Button("Resetar grade") {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        blocks = Array(repeating: GridBlock(), count: 9)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 24)
            .navigationTitle("Grid 3×3")
            .sheet(item: Binding(
                get: { selectedIndex.map { SheetIndex(value: $0) } },
                set: { newVal in selectedIndex = newVal?.value }
            )) { sheet in
                ScratchMiniGameView(
                    layer: blocks[sheet.value].layer
                ) {
                    // onComplete
                    if let idx = selectedIndex {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            blocks[idx].layer += 1
                        }
                    }
                    selectedIndex = nil
                } onCancel: {
                    selectedIndex = nil
                }
            }
        }
    }
    
    private struct SheetIndex: Identifiable {
        var id: Int { value }
        let value: Int
    }
    
    // Visual das camadas
    @ViewBuilder
    private func layerView(for layer: Int) -> some View {
        switch layer {
        case 0: // Grama
            LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                .overlay(Image(systemName: "leaf.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9)))
        case 1: // Terra
            LinearGradient(colors: [.brown.opacity(0.8), .brown], startPoint: .top, endPoint: .bottom)
                .overlay(Image(systemName: "mountain.2.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9)))
        case 2: // Pedra
            LinearGradient(colors: [.gray.opacity(0.7), .gray.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                .overlay(Image(systemName: "cube.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9)))
        default:
            Color.clear
        }
    }
}

// MARK: - Mini-game de raspadinha
struct ScratchMiniGameView: View {
    let layer: Int
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var clearedCells: Set<Int> = []
    @State private var gridPoints: [CGPoint] = []
    @State private var cols: Int = 26
    @State private var rows: Int = 0
    @State private var revealRatio: CGFloat = 0
    private let brushRadius: CGFloat = 35  // 🔥 Aumentado o tamanho do pincel
    private let targetRevealRatio: CGFloat = 0.8
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            ZStack {
                // Fundo depende da camada
                layerBackground(for: layer)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Ícone da camada no centro com leve animação
                VStack {
                    Image(systemName: layerSymbol(for: layer))
                        .font(.system(size: 120))
                        .foregroundStyle(.white.opacity(0.8))
                        .shadow(radius: 10)
                        .scaleEffect(1 + revealRatio * 0.3)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: revealRatio)
                }
                .opacity(0.25 + revealRatio * 0.4)
                
                // Máscara “sujeira”
                Canvas { context, _ in
                    for (i, point) in gridPoints.enumerated() {
                        if !clearedCells.contains(i) {
                            let rect = CGRect(
                                x: point.x - brushRadius,
                                y: point.y - brushRadius,
                                width: brushRadius * 2,
                                height: brushRadius * 2
                            )
                            context.fill(Path(ellipseIn: rect), with: .color(layerMaskColor(for: layer)))
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let p = value.location
                            let r2 = brushRadius * brushRadius
                            var changed = false
                            for (i, point) in gridPoints.enumerated() {
                                if !clearedCells.contains(i) {
                                    let dx = point.x - p.x
                                    let dy = point.y - p.y
                                    if (dx*dx + dy*dy) <= r2 {
                                        clearedCells.insert(i)
                                        changed = true
                                    }
                                }
                            }
                            if changed { updateRevealRatio() }
                        }
                )
                
                // HUD
                VStack {
                    HStack {
                        Button {
                            onCancel()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .padding(10)
                                .background(.thinMaterial, in: Circle())
                        }
                        Spacer()
                        Text("Limpeza: \(Int(revealRatio * 100))%")
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
            .onAppear { setupGrid(in: size) }
            .onChange(of: geo.size) { newSize in setupGrid(in: newSize) }
            .onChange(of: clearedCells) { _ in
                if revealRatio >= targetRevealRatio {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onComplete()
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
    
    // Cor da máscara de sujeira
    private func layerMaskColor(for layer: Int) -> Color {
        switch layer {
        case 0: return .green.opacity(0.9)
        case 1: return .brown.opacity(0.9)
        case 2: return .gray.opacity(0.9)
        default: return .clear
        }
    }
    
    // Ícone de cada camada
    private func layerSymbol(for layer: Int) -> String {
        switch layer {
        case 0: return "leaf.fill"
        case 1: return "mountain.2.fill"
        case 2: return "cube.fill"
        default: return "star.fill"
        }
    }
    
    private func setupGrid(in size: CGSize) {
        let inset: CGFloat = 24
        let w = size.width - inset * 2
        let h = size.height - inset * 2
        
        let stepX = w / CGFloat(cols)
        let stepY = stepX
        rows = Int(h / stepY)
        
        gridPoints = (0..<rows).flatMap { r in
            (0..<cols).map { c in
                CGPoint(x: inset + stepX * (CGFloat(c) + 0.5),
                        y: inset + stepY * (CGFloat(r) + 0.5))
            }
        }
    }
    
    private func updateRevealRatio() {
        revealRatio = CGFloat(clearedCells.count) / CGFloat(gridPoints.count)
    }
}

// MARK: - Preview
#Preview {
    ScratchGridGameView()
}

