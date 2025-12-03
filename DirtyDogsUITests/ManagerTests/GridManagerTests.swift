//
//  GridManagerTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 25/11/25.
//

import Testing
import SpriteKit
@testable import DirtyDogs

@MainActor
struct GridManagerTests {
    let gridManager: GridManager
    let scene: GameScene
    
    init() {
        let matchManager = MatchManager()
        scene = GameScene(matchManager: matchManager, size: CGSize(width: 300, height: 400), hapticService: HapticsService())
        gridManager = scene.gridManager
    }
    
    @Test("Setup Grid - Verify container and nodes creation")
    func setupGridCreation() {
        // Given
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
        
        // When
        gridManager.setupGrid()
        
        // Then
        let gridContainer = scene.children.first { $0.zPosition == 10 }
        #expect(gridContainer != nil)
        #expect(gridContainer?.children.count == 13)
    }
    
    @Test("Map generation creates correct number of blocks and items")
    func mapGenerationConstraints() {
        // Given
        
        // When
        let blocks = gridManager.createMap(horizontal: 3, vertical: 4)
        
        // Then
        #expect(blocks.count == 12)
        
        let allRewards = blocks.flatMap { $0.rewards.values }
        
        let bones = allRewards.filter { $0 == .bone }
        #expect(bones.count == 3, "Should have exactly 3 bones")
        
        let items = allRewards.filter { $0 == .bomb || $0 == .tint || $0 == .seed }
        #expect(items.count >= 9 && items.count <= 15, "Should have betweeen 9 and 15 items total")
    }
    
    @Test("Complete scratch logic reveals item correctly")
    func completeScratchRevealLogic() {
        // Given
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
        
        var block = gridManager.blocks[0]
        let currentLayer = 1
        block.layer = currentLayer
        block.rewards[currentLayer] = .bomb
        gridManager.blocks[0] = block
        
        // When
        let reward = gridManager.completeScratch(at: 0)
        
        // Then
        #expect(reward == .bomb, "Should return the reward localized at the scratched layer")
        #expect(gridManager.blocks[0].layer == currentLayer + 1, "Layer should increment after scratch")
    }
    
    @Test("Reset grid restores initial state")
    func resetGridResetsData() {
        // Given
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
        gridManager.blocks[0].layer = 3
        
        // When
        gridManager.resetGrid()
        
        // Then
        #expect(gridManager.blocks[0].layer == 0)
        #expect(gridManager.blocks.count == 12)
    }
}
