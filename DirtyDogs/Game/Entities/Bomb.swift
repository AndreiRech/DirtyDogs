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
  
    private var wasReceived: Bool = false
    private var bombSize: CGFloat = 45

    public var node: SKNode? {
        component(ofType: GKSKNodeComponent.self)?.node
    }

    public var body: SKPhysicsBody? {
        node?.physicsBody
    }

    override public init() {
        super.init()

        let container = SKNode()
        container.name = "bomb"

        let bomb = SKSpriteNode(imageNamed: "Bomb")
        bomb.size = CGSize(width: bombSize * 2, height: bombSize * 2)
        bomb.name = "bomb"
        container.addChild(bomb)

        container.physicsBody = SKPhysicsBody(circleOfRadius: bombSize)

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
        container.zPosition = 100

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

    public func startFuseAnimation() {
        guard let container = component(ofType: GKSKNodeComponent.self)?.node,
              let bombSprite = container.children.first(where: { $0.name == "bomb" }) as? SKSpriteNode
        else { return }
        
        let frame1 = SKTexture(imageNamed: "Bomb")
        let frame2 = SKTexture(imageNamed: "Red")

        let flicker = SKAction.animate(with: [frame1, frame2],
                                       timePerFrame: 0.08,
                                       resize: false,
                                       restore: false)

        bombSprite.run(.repeatForever(flicker))
    }
    
    func setReceived(value: Bool) { wasReceived = value }
    func getReceived() -> Bool { wasReceived }
}
