//
//  Seed.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 25/11/25.
//

import Foundation
import SpriteKit
import GameplayKit

public class Seed: GKEntity, GameEntity {
    
    var wasReceived: Bool = false
    var seedSize: CGFloat = 40
    
    public var node: SKNode? {
        component(ofType: GKSKNodeComponent.self)?.node
    }
    
    public var body: SKPhysicsBody? {
        node?.physicsBody
    }
    
    override public init() {
        super.init()
        
        let node = SKShapeNode(circleOfRadius: seedSize)
        
        node.name = "ball"
        node.fillColor = .systemPink
        node.zPosition = 100
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: seedSize)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.parcel
        node.physicsBody?.collisionBitMask = PhysicsCategory.parcel | PhysicsCategory.edge
        node.physicsBody?.contactTestBitMask = 0
        node.physicsBody?.linearDamping = 5
        node.physicsBody?.angularDamping = 5
        node.physicsBody?.restitution = 0.9
        node.physicsBody?.friction = 0.0
        node.physicsBody?.usesPreciseCollisionDetection = true
        
        addComponent(GKSKNodeComponent(node: node))
        
        let draggableComponent = DraggableComponent()
        addComponent(draggableComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setPosition(to point: CGPoint) {
        component(ofType: GKSKNodeComponent.self)?.node.position = point
    }
    
    func setReceived(value: Bool) { wasReceived = value }
    func getReceived() -> Bool { wasReceived }
}
