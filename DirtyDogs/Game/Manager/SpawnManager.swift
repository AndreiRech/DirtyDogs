//
//  SpawnManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 21/11/25.
//

import SpriteKit
import GameplayKit

class SpawnManager {
    weak var entityManager: EntityManager?
    weak var fxManager: ScreenFXManager?
    
    init(entityManager: EntityManager?, fxManager: ScreenFXManager?) {
        self.entityManager = entityManager
        self.fxManager = fxManager
    }
    
    // Cria uma entidade em uma posição específica
    func spawnItem(at point: CGPoint, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        value.setPosition(to: point)
        entityManager?.add(entity: value)
    }
    
    // Cria uma entidade em movimento
    func spawnItem(at point: CGPoint, goingTo side: EdgeSide, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        value.setPosition(to: point)
        value.setReceived(value: true)
        entityManager?.add(entity: value)
        
        value.body?.applyForce(.init(dx: 0, dy: -25000))
        
        executeAction(value: value)
    }
    
    private func getItemType(entity: PhysicsObjectType) -> GameEntity {
        switch entity {
        case .ball:
            return Ball()
        case .bomb:
            return Bomb()
        case .poop:
            return Poop()
        }
    }
    
    func executeAction(value: GameEntity) {
        if let bomb = value as? Bomb {
            bomb.startFuseAnimation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                guard let self = self, let fx = self.fxManager else { return }
                if let node = bomb.node {
                    fx.explode(node: node, entity: bomb)
                }
            }
        }
        
        if let poop = value as? Poop {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                guard let self = self, let fx = self.fxManager else { return }
                if let node = poop.node {
                    fx.explodePoop(node: node, entity: poop)
                }
            }
        }
    }
}
