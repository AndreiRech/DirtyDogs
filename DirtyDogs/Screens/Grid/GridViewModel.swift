//
//  GridViewModel.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI
import SpriteKit

@Observable
class GridViewModel: GridViewModelProtocol {
    var matchManager: MatchManager
    var gameScene: GameScene
    
    var blocks: [GridBlock] = Array(repeating: GridBlock(), count: 9)
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var selectedIndex: Int? = nil
    
    init(matchManager: MatchManager, gameScene: GameScene) {
        self.matchManager = matchManager
        self.gameScene = gameScene
    }
    
    func resetGrid() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            self.blocks = Array(repeating: GridBlock(), count: 9)
        }
    }
    
    func spawnBall() {
        let spawnPoint = CGPoint(
            x: gameScene.frame.midX,
            y: gameScene.frame.maxY - 100
        )
        gameScene.spawnManager.spawnItem(at: spawnPoint, entity: .ball)
    }
    
    func completeScratch(at index: Int) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            blocks[index].layer += 1
        }
        self.selectedIndex = nil
    }
    
    func cancelScratch() {
        self.selectedIndex = nil
    }
}
