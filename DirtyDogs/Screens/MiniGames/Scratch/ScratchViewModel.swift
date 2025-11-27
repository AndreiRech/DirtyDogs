//
//  ScratchViewModel.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

@Observable
class ScratchViewModel: ScratchViewModelProtocol {
    let layer: Int
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    var clearedCells: Set<Int> = []
    var gridPoints: [CGPoint] = []
    var cols: Int = 26
    var rows: Int = 0
    var revealRatio: CGFloat = 0
    let brushRadius: CGFloat = 40
    let targetRevealRatio: CGFloat = 0.8
    var wasCleared: Bool = false
    
    init(layer: Int, onComplete: @escaping () -> Void, onCancel: @escaping () -> Void, clearedCells: Set<Int> = [], gridPoints: [CGPoint] = [], cols: Int = 26, rows: Int = 0, revealRatio: CGFloat = 0) {
        self.layer = layer
        self.onComplete = onComplete
        self.onCancel = onCancel
        self.clearedCells = clearedCells
        self.gridPoints = gridPoints
        self.cols = cols
        self.rows = rows
        self.revealRatio = revealRatio
    }
    
    // Cor da máscara de sujeira
    func layerMaskColor(for layer: Int) -> Color {
        switch layer {
        case 0: return .green.opacity(0.9)
        case 1: return .brown.opacity(0.9)
        case 2: return .gray.opacity(0.9)
        default: return .clear
        }
    }
    
    // Ícone de cada camada
    func layerSymbol(for layer: Int) -> String {
        switch layer {
        case 0: return "leaf.fill"
        case 1: return "mountain.2.fill"
        case 2: return "cube.fill"
        default: return "star.fill"
        }
    }
    
    func setupGrid(in size: CGSize) {
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
    
    func updateRevealRatio() {
        revealRatio = CGFloat(clearedCells.count) / CGFloat(gridPoints.count)
    }
}
