//
//  GameViewModelTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 25/11/25.
//

import Testing
import SpriteKit
import SwiftUI
@testable import DirtyDogs

@MainActor
struct GameViewModelTests {
    let gridManager: GridManager
    let entityManager: EntityManager
    let scene: GameScene
    let viewModel: GameViewModel
    let mockHaptics: MockHapticsService
    let matchManager: MatchManager

    init() {
        matchManager = MatchManager()
        mockHaptics = MockHapticsService()
        
        viewModel = GameViewModel(matchManager: matchManager, hapticsService: mockHaptics)
        scene = viewModel.gameScene
        gridManager = scene.gridManager
        entityManager = scene.entityManager
    }
    
    @Test("Bones found counter increments correctly when a bone is revealed")
    func boneFoundIncrementsCounter() {
        // Given
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
        
        #expect(viewModel.bonesFound == 0)
        
        // When
        var block = GridBlock(layer: 0)
        block.rewards[0] = .bone
        gridManager.blocks[0] = block
        
        // Then
        viewModel.completeScratch(at: 0)
        
        #expect(viewModel.bonesFound == 1)
    }
    
    @Test("Game Ends Victory when 3 bones are found")
    func gameEndsVictory() {
        // Given
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
        
        viewModel.bonesFound = 2
        
        // When
        var block = GridBlock(layer: 0)
        block.rewards[0] = .bone
        gridManager.blocks[0] = block
        
        // Then
        viewModel.completeScratch(at: 0)
        
        #expect(viewModel.bonesFound == 3)
        #expect(matchManager.isGameOver == true)
    }

    @Test("Spawn item adds a new entity to the scene")
    func spawnItemAddsEntityToScene() {
        // Given
        let initialCount = entityManager.getEntities().count
        
        #expect(initialCount == 0)
        
        // When
        viewModel.spawnItem(type: .bomb, spawnPoint: nil)
        
        // Then
        let newCount = entityManager.getEntities().count
        #expect(newCount == initialCount + 1)
        
        let hasBomb = entityManager.getEntities().contains { $0 is Bomb }
        #expect(hasBomb, "The entity should be a bomb")
    }
    
    @Test("Inventory: Did Collect Item")
    func inventoryCollectLogic() {
        // Given
        #expect(viewModel.availableItems.filter { $0 == nil }.count == 3)
        
        // When
        let item = InventoryItem(id: UUID(), imageName: "Bomb-Button")
        viewModel.didCollect(item: item)
        
        // Then
        let itemsCount = viewModel.availableItems.filter { $0 != nil }.count
        #expect(itemsCount == 1)
        #expect(viewModel.availableItems.contains(where: { $0?.imageName == "Bomb-Button" }))
    }
    
    @Test("Inventory: Did Use Item spawns entity and clears slot")
    func inventoryUseLogic() {
        // Given
        let item = InventoryItem(id: UUID(), imageName: "Seed-Button")
        viewModel.availableItems[0] = item
        
        let initialEntities = entityManager.getEntities().count
        
        // When
        viewModel.didUse(item: item)
        
        // Then
        #expect(viewModel.availableItems[0] == nil)
        
        let finalEntities = entityManager.getEntities().count
        #expect(finalEntities == initialEntities + 1)
        
        let hasSeed = entityManager.getEntities().contains { $0 is Seed }
        #expect(hasSeed)
    }
    
    @Test("Haptics are triggered on interaction")
    func hapticsTrigger() {
        // Given
        
        // When
        viewModel.playHaptics(sound: .gridTouch)
        
        // Then
        #expect(mockHaptics.lastHaptics == .gridTouch)
    }
}
