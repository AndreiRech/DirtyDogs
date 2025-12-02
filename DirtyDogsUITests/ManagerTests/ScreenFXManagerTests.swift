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
        let scene = SKScene()
        let fxManager = ScreenFXManager(scene: scene, entityManager: nil, hapticsService: HapticsService())
        
        // When
        fxManager.applyStun(duration: 0.1)
        
        // Then
        #expect(fxManager.isStunned == true)
        #expect(scene.childNode(withName: "stunOverlay") != nil)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(fxManager.isStunned == false)
        #expect(scene.childNode(withName: "stunOverlay") == nil)
    }
    
    @Test("Explode - Verify entity removal from manager")
    func explodeRemovesEntity() {
        // Given
        let scene = GameScene(matchManager: MatchManager(), size: CGSize(width: 500, height: 800), hapticService: HapticsService())
        let entityManager = EntityManager(scene: scene)
        let fxManager = ScreenFXManager(scene: scene, entityManager: entityManager, hapticsService: HapticsService())
        
        let ball = Ball()
        let node = SKShapeNode(circleOfRadius: 10)
        scene.addChild(node)
        entityManager.add(entity: ball)
        
        // When
        fxManager.explode(node: node, entity: ball)
        
        // Then
        #expect(entityManager.getEntities().contains(ball) == false)
    }
}
