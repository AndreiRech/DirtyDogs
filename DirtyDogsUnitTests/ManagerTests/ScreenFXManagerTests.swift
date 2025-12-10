//
//  ScreenFXManagerTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 26/11/25.
//

import Testing
import SpriteKit
@testable import DirtyDogs

@MainActor
struct ScreenFXManagerTests {
    @Test("Apply Stun - Verify overlay and state duration")
    func applyStunState() async throws {
        // Given
        let scene = GameScene(matchManager: MatchManager(), size: CGSize(width: 500, height: 800), hapticService: HapticsService())
        let fxManager = ScreenFXManager(scene: scene, entityManager: nil, hapticsService: HapticsService())
        
        // When
        fxManager.applyStun(duration: 0.1, timer: true)
        
        // Then
        #expect(fxManager.isStunned == true)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(fxManager.isStunned == false)
    }
    
    @Test("Explode - Verify entity removal from manager")
    func explodeRemovesEntity() async throws {
        // Given
        let scene = GameScene(matchManager: MatchManager(), size: CGSize(width: 500, height: 800), hapticService: HapticsService())
        let entityManager = EntityManager(scene: scene)
        let fxManager = ScreenFXManager(scene: scene, entityManager: entityManager, hapticsService: HapticsService())
        
        let bomb = Bomb()
        let node = SKShapeNode(circleOfRadius: 10)
        scene.addChild(node)
        entityManager.add(entity: bomb)
        
        // When
        fxManager.explode(node: node, entity: bomb)
        
        // Then
        try await Task.sleep(nanoseconds: 3_000_000_000)
        #expect(entityManager.getEntities().contains(bomb) == false)
    }
}
