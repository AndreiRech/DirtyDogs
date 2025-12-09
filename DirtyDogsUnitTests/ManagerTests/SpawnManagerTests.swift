//
//  SpawnManagerTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 25/11/25.
//

import Testing
import SpriteKit
import GameplayKit
@testable import DirtyDogs

@MainActor
struct SpawnManagerTests {
    let spawnManager: SpawnManager
    let entityManager: EntityManager
    
    init() {
        let matchManager = MatchManager()
        let scene = GameScene(matchManager: matchManager, size: CGSize(width: 100, height: 100), hapticService: HapticsService())
        entityManager = EntityManager(scene: scene)
        spawnManager = SpawnManager(entityManager: entityManager, fxManager: nil)
    }
    
    @Test("Spawn Static Item - Verify entity addition and position")
    func spawnStaticItem() {
        // Given
        let targetPosition = CGPoint(x: 100, y: 200)
        
        // When
        spawnManager.spawnItem(at: targetPosition, entity: .ball)
        
        // Then
        let entities = entityManager.getEntities()
        let ball = entities.first { $0 is Ball }
        
        #expect(entities.count == 1)
        #expect(ball != nil)
        if let node = ball?.component(ofType: GKSKNodeComponent.self)?.node {
            #expect(node.position == targetPosition)
        }
    }
    
    @Test("Spawn Moving Item - Verify force application capability")
    func spawnMovingItem() {
        // Given
        let scene = GameScene(matchManager: MatchManager(), size: CGSize(width: 500, height: 800), hapticService: HapticsService())
        let entityManager = EntityManager(scene: scene)
        let spawnManager = SpawnManager(entityManager: entityManager, fxManager: nil)
        
        // When
        spawnManager.spawnItem(at: .zero, goingTo: .top, entity: .bomb)
        
        // Then
        let bomb = entityManager.getEntities().first { $0 is Bomb } as? GameEntity
        #expect(bomb != nil)
        #expect(bomb?.getReceived() == true)
        #expect(bomb?.body != nil)
    }
    
    @Test("Execute Action - Bomb explosion removes entity")
    func executeActionBombExplosion() async throws {
        // Given
        let scene = GameScene(matchManager: MatchManager(), size: CGSize(width: 500, height: 800), hapticService: HapticsService())
        let entityManager = EntityManager(scene: scene)
        let fxManager = ScreenFXManager(scene: scene, entityManager: entityManager, hapticsService: HapticsService())
        let spawnManager = SpawnManager(entityManager: entityManager, fxManager: fxManager)
        
        let bomb = Bomb()
        entityManager.add(entity: bomb)
        
        // When
        spawnManager.executeAction(value: bomb)
        
        // Then
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        let hasBomb = entityManager.getEntities().contains(bomb)
        #expect(!hasBomb)
    }
}
