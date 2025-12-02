//
//  Poop.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 21/11/25.
//

import Foundation
import SpriteKit
import GameplayKit

public class Tint: GKEntity, GameEntity {

    private var sizeBase: CGFloat = 45
    private var wasReceived: Bool = false
    
    public var node: SKNode? {
        component(ofType: GKSKNodeComponent.self)?.node
    }

    public var body: SKPhysicsBody? {
        node?.physicsBody
    }

    override public init() {
        super.init()

        let container = SKNode()
        container.name = "tint"

        let bomb = SKSpriteNode(imageNamed: "Tint")
        bomb.size = CGSize(width: sizeBase * 2, height: sizeBase * 2)
        bomb.name = "tint"
        container.addChild(bomb)

        container.physicsBody = SKPhysicsBody(circleOfRadius: sizeBase)

        container.physicsBody = SKPhysicsBody(circleOfRadius: sizeBase)
        container.physicsBody?.affectedByGravity = false
        container.physicsBody?.categoryBitMask = PhysicsCategory.parcel
        container.physicsBody?.collisionBitMask = PhysicsCategory.parcel | PhysicsCategory.edge
        container.physicsBody?.contactTestBitMask = 0
        container.physicsBody?.linearDamping = 4
        container.physicsBody?.angularDamping = 4
        container.physicsBody?.restitution = 0.2
        container.physicsBody?.friction = 0.1
        container.zPosition = 100

        addComponent(GKSKNodeComponent(node: container))

        addComponent(DraggableComponent())
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
