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
    let isClear: Bool
    let onComplete: () -> Void
    let reward: Reward
    var showResult: Bool = false
    
    var clearedCells: Set<Int> = []
    var gridPoints: [CGPoint] = []
    var cols: Int = 60
    var rows: Int = 0
    var revealRatio: CGFloat = 0
    let brushRadius: CGFloat = 20
    let targetRevealRatio: CGFloat = 0.7
    var wasCleared: Bool = false
    
    init(layer: Int, isClear: Bool, reward: Reward, onComplete: @escaping () -> Void, clearedCells: Set<Int> = [], gridPoints: [CGPoint] = [], cols: Int = 26, rows: Int = 0, revealRatio: CGFloat = 0) {
        self.layer = layer
        self.isClear = isClear
        self.reward = reward
        self.onComplete = onComplete
        self.clearedCells = clearedCells
        self.gridPoints = gridPoints
        self.cols = cols
        self.rows = rows
        self.revealRatio = revealRatio
    }
    
    func getImage(nextLayer: Bool = false) -> String {
        var actualLayer = layer
        if nextLayer { actualLayer += 1 }
        
        switch actualLayer {
        case 0:
            return isClear ? "Grass-Light" : "Grass-Dark"
        case 1:
            return isClear ? "Dirt-Dark" : "Dirt-Light"
        case 2:
            return isClear ? "Stone-Dark" : "Stone-Light"
        default:
            return "checkmark.circle.fill"
        }
    }
    
    func getRewardImage() -> String {
        switch reward {
        case .bomb:
            return "Bomb-Button"
        case .poop:
            return "Tint-Button"
        case .seed:
            return "Seed-Button"
        case .bone:
            return "Bone"
        default:
            return ""
        }
    }
    
    func setupGrid(in size: CGSize) {
        let inset: CGFloat = 4
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
