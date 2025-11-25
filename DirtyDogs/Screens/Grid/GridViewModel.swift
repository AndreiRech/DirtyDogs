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
    
    var blocks: [GridBlock] = []
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var selectedIndex: Int? = nil
    
    private var hapticsService: HapticsServiceProtocol
    
    init(matchManager: MatchManager, gameScene: GameScene, hapticService: HapticsServiceProtocol) {
        self.matchManager = matchManager
        self.gameScene = gameScene
        self.hapticsService = hapticService
        
        blocks = gameScene.gridManager.createMap(horizontal: 3, vertical: 4)
        gameScene.gridManager.updateData(blocks: self.blocks)
        
        self.hapticsService.prepareHaptics()
    }
    
    func resetGrid() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            blocks = gameScene.gridManager.createMap(horizontal: 3, vertical: 4)
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
            
            let block = blocks[index]
            
            gameScene.gridManager.updateData(blocks: self.blocks)
            
            if block.reward != .none && block.rewardLayer == block.layer - 1 {
                switch block.reward {
                case .bone:
                    print("Osso!!!!!!!!!!!!!!!!!")
                    hapticsService.findItem()
                case .bomb, .poop:
                    guard let entity = block.reward.toPhysicsObject else { return }
                    
                    let spawnPoint = CGPoint(
                        x: gameScene.frame.midX,
                        y: gameScene.frame.maxY - 100
                    )
                    gameScene.spawnManager.spawnItem(at: spawnPoint, entity: entity)
                    
                    hapticsService.findItem()
                default :
                    break
                }
            }
        }
        self.selectedIndex = nil
    }
    
    func cancelScratch() {
        self.selectedIndex = nil
    }
}
