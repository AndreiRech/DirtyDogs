//
//  EntityManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation
import GameplayKit
import SpriteKit

public final class EntityManager {
    private var entities = Set<GKEntity>()
    private var scene: SKScene

    init(scene: SKScene) {
        self.scene = scene
    }

    func add(entity: GKEntity) {
        entities.insert(entity)

        if let node = entity.component(ofType: GKSKNodeComponent.self)?.node {
            scene.addChild(node)
        }
    }
    
    func remove(entity: GKEntity) {
        entities.remove(entity)
        
        if let node = entity.component(ofType: GKSKNodeComponent.self)?.node {
            node.removeFromParent()
        }
    }
    
    func getEntities() -> Set<GKEntity> {
        entities
    }
}

// Hit-test helpers
extension EntityManager {
    func entity(at point: CGPoint) -> GKEntity? {
        let candidates: [(GKEntity, SKNode)] = entities.compactMap { entity in
            guard
                entity.component(ofType: DraggableComponent.self) != nil,
                let node = entity.component(ofType: GKSKNodeComponent.self)?.node,
                node.contains(point),
                node.physicsBody != nil
            else { return nil }
            return (entity, node)
        }
        
        return candidates.max(by: { $0.1.zPosition < $1.1.zPosition })?.0
    }
    
    public func node(for entity: GKEntity) -> SKNode? {
        entity.component(ofType: GKSKNodeComponent.self)?.node
    }
}
