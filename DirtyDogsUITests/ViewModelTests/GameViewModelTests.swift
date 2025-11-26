//
//  GameViewModelTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 25/11/25.
//

import Testing
import SpriteKit
@testable import DirtyDogs

@MainActor
struct GameViewModelTests {
    let gridManager: GridManager
    let entityManager: EntityManager
    let scene: GameScene
    let viewModel: GameViewModelProtocol
    
    init() {
        let matchManager = MatchManager()
        let mockSpeech = MockSpeechService()
        viewModel = GameViewModel(matchManager: matchManager, speechService: mockSpeech)
        scene = viewModel.gameScene
        gridManager = scene.gridManager
        entityManager = scene.entityManager
    }
    
    @Test("Bones found counter increments correctly when a bone is revealed")
    func boneFoundIncrementsCounter() {
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
        
        #expect(viewModel.bonesFound == 0)
        
        gridManager.blocks[0] = GridBlock(layer: 0, reward: .bone, rewardLayer: 0)
        
        viewModel.completeScratch(at: 0)
        
        #expect(viewModel.bonesFound == 1)
    }
    
    @Test("Spawn item adds a new entity to the scene")
    func spawnItemAddsEntityToScene() {
        let initialCount = entityManager.getEntities().count
        
        #expect(initialCount == 0)
        
        viewModel.spawnItem(type: .bomb)
        
        let newCount = entityManager.getEntities().count
        #expect(newCount == initialCount + 1)
        
        let hasBomb = entityManager.getEntities().contains { $0 is Bomb }
        #expect(hasBomb, "The entity should be a bomb")
    }
}
