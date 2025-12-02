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
        #expect(blocks.count == 36)
        
        let bones = blocks.filter { $0.reward == .bone }
        #expect(bones.count == 3, "Should have exactly 3 bones")
        
        let items = blocks.filter { $0.reward == .bomb || $0.reward == .poop || $0.reward == .seed }
        #expect(items.count >= 9 && items.count <= 15, "Should have between 3 and 5 items forEach item")
    }
    
    @Test("Complete scratch logic reveals item correctly")
    func completeScratchRevealLogic() {
        // Given
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
        
        var block = gridManager.blocks[0]
        block.layer = 2
        block.reward = .bomb
        block.rewardLayer = 2
        gridManager.blocks[0] = block
        
        // When
        let reward = gridManager.completeScratch(at: 0)
        
        // Then
        #expect(reward == .bomb)
        #expect(gridManager.blocks[0].layer == 3)
        #expect(gridManager.blocks[0].cleared)
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
        #expect(gridManager.blocks.count == 36)
    }
}
