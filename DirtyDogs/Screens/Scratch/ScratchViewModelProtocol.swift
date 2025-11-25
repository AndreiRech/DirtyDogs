//
//  ScratchViewModelProtocol.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

protocol ScratchViewModelProtocol {
    var layer: Int { get }
    var onComplete: () -> Void { get }
    var onCancel: () -> Void { get }
    var clearedCells: Set<Int> { get set }
    var gridPoints: [CGPoint] { get set }
    var cols: Int { get set }
    var rows: Int { get set }
    var revealRatio: CGFloat { get set }
    var brushRadius: CGFloat { get }
    var targetRevealRatio: CGFloat { get }
    var wasCleared: Bool { get set }
    
    func layerMaskColor(for layer: Int) -> Color
    func layerSymbol(for layer: Int) -> String
    func setupGrid(in size: CGSize)
    func updateRevealRatio()
}
