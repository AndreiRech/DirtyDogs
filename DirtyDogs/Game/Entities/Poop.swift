//
//  Poop.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 21/11/25.
//

import Foundation
import SpriteKit
import GameplayKit

public class Poop: GKEntity, GameEntity {

    private var sizeBase: CGFloat = 40
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
        container.name = "poop"

        let base = SKShapeNode(circleOfRadius: sizeBase)
        base.fillColor = UIColor(red: 0.36, green: 0.20, blue: 0.04, alpha: 1.0) // marrom escuro
        base.strokeColor = base.fillColor.withAlphaComponent(0.7)
        base.position = CGPoint(x: 0, y: 0)

        let middle = SKShapeNode(circleOfRadius: sizeBase * 0.7)
        middle.fillColor = base.fillColor
        middle.strokeColor = base.strokeColor
        middle.position = CGPoint(x: 0, y: sizeBase * 0.8)

        let top = SKShapeNode(circleOfRadius: sizeBase * 0.45)
        top.fillColor = base.fillColor
        top.strokeColor = base.strokeColor
        top.position = CGPoint(x: 0, y: sizeBase * 1.45)

        container.addChild(base)
        container.addChild(middle)
        container.addChild(top)
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
