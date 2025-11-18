//
//  Bomb.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 18/11/25.
//


import Foundation
import SpriteKit
import GameplayKit

public class Bomb: GKEntity, GameEntity {

    private var bombSize: CGFloat = 45

    public var node: SKNode? {
        component(ofType: GKSKNodeComponent.self)?.node
    }

    public var body: SKPhysicsBody? {
        node?.physicsBody
    }

    override public init() {
        super.init()

        // Corpo principal da bomba
        let circle = SKShapeNode(circleOfRadius: bombSize)
        circle.fillColor = .black
        circle.strokeColor = .gray
        circle.lineWidth = 4

        // Pavio da bomba
        let fuse = SKShapeNode(rectOf: CGSize(width: 10, height: 22), cornerRadius: 3)
        fuse.fillColor = .orange
        fuse.strokeColor = .red
        fuse.position = CGPoint(x: 0, y: bombSize + 12)
        fuse.name = "fuse" // importante para animar depois

        // Nó container
        let container = SKNode()
        container.name = "bomb"
        container.addChild(circle)
        container.addChild(fuse)

        container.physicsBody = SKPhysicsBody(circleOfRadius: bombSize)
        container.physicsBody?.affectedByGravity = false
        container.physicsBody?.categoryBitMask = PhysicsCategory.parcel
        container.physicsBody?.collisionBitMask = PhysicsCategory.parcel | PhysicsCategory.edge
        container.physicsBody?.contactTestBitMask = 0
        container.physicsBody?.linearDamping = 5
        container.physicsBody?.angularDamping = 5
        container.physicsBody?.restitution = 0.9
        container.physicsBody?.friction = 0.0
        container.physicsBody?.usesPreciseCollisionDetection = true

        addComponent(GKSKNodeComponent(node: container))

        let draggableComponent = DraggableComponent()
        addComponent(draggableComponent)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setPosition(to point: CGPoint) {
        component(ofType: GKSKNodeComponent.self)?.node.position = point
    }

    // Pavio piscando rapidinho (amarelo/vermelho)
    public func startFuseAnimation() {
        guard
            let container = component(ofType: GKSKNodeComponent.self)?.node,
            let fuse = container.children.first(where: { $0.name == "fuse" }) as? SKShapeNode
        else { return }

        let flicker = SKAction.sequence([
            .run { fuse.fillColor = .yellow },
            .wait(forDuration: 0.08),
            .run { fuse.fillColor = .red },
            .wait(forDuration: 0.08)
        ])

        fuse.run(.repeatForever(flicker))
        
        // Bombinha “pulsando” levemente
        let pulseUp = SKAction.scale(to: 1.08, duration: 0.12)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.12)
        container.run(.repeatForever(.sequence([pulseUp, pulseDown])))
    }
}
