//
//  InputManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 21/11/25.
//

import SpriteKit
import GameplayKit

class InputManager {
    weak var scene: SKScene?
    weak var entityManager: EntityManager?
    weak var fxManager: ScreenFXManager?
    
    private var isDragging = false
    private var currentDrag: GKEntity?
    private var targetPoint: CGPoint?
    
    init(scene: SKScene, entityManager: EntityManager?, fxManager: ScreenFXManager?) {
        self.scene = scene
        self.entityManager = entityManager
        self.fxManager = fxManager
    }
    
    func handleTouchesBegan(_ touches: Set<UITouch>) {
        if fxManager?.isStunned == true { return }
        
        guard let scene = scene, let manager = entityManager else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: scene)
        
        if let entity = manager.entity(at: location),
           let node = manager.node(for: entity),
           let body = node.physicsBody {
            
            isDragging = true
            currentDrag = entity
            targetPoint = location
            body.angularVelocity = 0
        }
    }    
    
    func handleTouchesMoved(_ touches: Set<UITouch>) {
        if fxManager?.isStunned == true { return }
        guard let scene = scene, let touch = touches.first else { return }
        targetPoint = touch.location(in: scene)
    }
    
    func handleTouchesEnded() {
        endDrag()
    }
    
    private func endDrag() {
        isDragging = false
        
        if let manager = entityManager,
           let entity = currentDrag,
           let node = manager.node(for: entity) {
            node.physicsBody?.angularVelocity = 0
        }
        
        currentDrag = nil
        targetPoint = nil
    }
    
    func update() {
        guard let manager = entityManager,
              let entity = currentDrag,
              let node = manager.node(for: entity),
              let body = node.physicsBody,
              let target = targetPoint else { return }
        
        let pos = node.position
        let dx = target.x - pos.x
        let dy = target.y - pos.y
        let dist = sqrt(dx * dx + dy * dy)
        
        if dist < 0.5 {
            body.velocity = .zero
            return
        }
        
        let stiffness: CGFloat = 20
        let damping: CGFloat = 10
        
        let desiredVx = dx * stiffness
        let desiredVy = dy * stiffness
        
        let steerX = desiredVx - body.velocity.dx
        let steerY = desiredVy - body.velocity.dy
        
        let force = CGVector(dx: steerX * damping, dy: steerY * damping)
        body.applyForce(force)
        
        let maxSpeed: CGFloat = 1000
        var velocity = body.velocity
        let speed = hypot(velocity.dx, velocity.dy)
        if speed > maxSpeed {
            velocity.dx = velocity.dx / speed * maxSpeed
            velocity.dy = velocity.dy / speed * maxSpeed
            body.velocity = velocity
        }
    }
}
