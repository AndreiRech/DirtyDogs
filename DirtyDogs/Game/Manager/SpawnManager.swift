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
    weak var gridManager: GridManager?
    
    init(entityManager: EntityManager?, fxManager: ScreenFXManager?, gridManager: GridManager? = nil) {
        self.entityManager = entityManager
        self.fxManager = fxManager
        self.gridManager = gridManager
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
        case .tint:
            return Tint()
        case .seed:
            return Seed()
        }
    }
    
    func executeAction(value: GameEntity) {
        if let bomb = value as? Bomb {
            bomb.startFuseAnimation()
            
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(0.75))
                guard let self = self, let fx = self.fxManager else { return }
                if let node = bomb.node {
                    fx.explode(node: node, entity: bomb)
                }
            }
        }
        
        if let tint = value as? Tint {
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(0.4))
                guard let self = self, let fx = self.fxManager else { return }
                if let node = tint.node {
                    fx.explodePoop(node: node, entity: tint)
                }
            }
        }
        
        if let seed = value as? Seed {
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(1))
                guard let self = self, let fx = self.fxManager else { return }
                if let node = seed.node {
                    fx.explodeSeed(node: node, entity: seed, gridManager: self.gridManager)
                }
            }
        }
    }
}
