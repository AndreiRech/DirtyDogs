//
//  ScratchViewModelProtocol.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

protocol ScratchViewModelProtocol {
    var layer: Int { get }
    var isClear: Bool { get }
    var onComplete: () -> Void { get }
    
    var reward: Reward { get }
    var showResult: Bool { get set }
    
    var clearedCells: Set<Int> { get set }
    var gridPoints: [CGPoint] { get set }
    var cols: Int { get set }
    var rows: Int { get set }
    var revealRatio: CGFloat { get set }
    var brushRadius: CGFloat { get }
    var targetRevealRatio: CGFloat { get }
    var wasCleared: Bool { get set }
    
    func setupGrid(in size: CGSize)
    func updateRevealRatio()
    func getImage(nextLayer: Bool) -> String
    func getRewardImage() -> String
}
