//
//  PhysicsScene.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SpriteKit
import GameplayKit
import GameKit

public final class PhysicsScene: SKScene {
    private var matchManager: MatchManager
    private var entityManager: EntityManager?
    
    init(matchManager: MatchManager, size: CGSize) {
        self.matchManager = matchManager
        super.init(size: size)
    }
    
    public override convenience init(size: CGSize) {
        fatalError("Use PhysicsScene(matchManager:size:) instead")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isDragging = false
    private var currentDrag: GKEntity?
    private var targetPoint: CGPoint?
    
    override public func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        physicsWorld.gravity = .init(dx: 0, dy: 9.6)
        
        setupBorders()
        
        self.entityManager = EntityManager(scene: self)
        
        spawnBall(entity: .ball)
    }
    
    private func setupBorders() {
        self.physicsBody = nil
        var bodies = [SKPhysicsBody]()
        
        let bottomEdge = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.minY))
        bodies.append(bottomEdge)
        
        let leftEdge = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.minX, y: frame.maxY))
        bodies.append(leftEdge)
        
        let rightEdge = SKPhysicsBody(edgeFrom: CGPoint(x: frame.maxX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.maxY))
        bodies.append(rightEdge)
        
        let edgeBody = SKPhysicsBody(bodies: bodies)
        edgeBody.categoryBitMask = PhysicsCategory.edge
        
        edgeBody.isDynamic = false
        edgeBody.affectedByGravity = false
        edgeBody.allowsRotation = false
        
        self.physicsBody = edgeBody
    }
    
    // MARK: - Touch funcs
    override public func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard
            let touch = touches.first,
            let manager = entityManager
        else { return }
        
        let location = touch.location(in: self)
        
        guard
            let entity = manager.entity(at: location),
            let node = manager.node(for: entity),
            let body = node.physicsBody
        else { return }
        
        isDragging = true
        currentDrag = entity
        targetPoint = location
        body.angularVelocity = 0
    }
    
    override public func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard let touch = touches.first else { return }
        targetPoint = touch.location(in: self)
    }
    
    override public func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        endDrag()
    }
    
    override public func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        endDrag()
    }
    
    private func endDrag() {
        isDragging = false
        
        defer {
            currentDrag = nil
            targetPoint = nil
        }
        
        guard
            let manager = entityManager,
            let entity = currentDrag,
            let node = manager.node(for: entity),
            let body = node.physicsBody
        else { return }
        
        body.angularVelocity = 0
    }
    
    override public func update(_ currentTime: TimeInterval) {
        handleMovementUpdate()
        
        guard let entities = entityManager?.getEntities() else { return }
        
        for entity in entities {
            if let node = entity.component(ofType: GKSKNodeComponent.self)?.node {
                if let side = exitSide(for: node) {
                    sendParcel(side: side, node: node, entity: entity as! GameEntity)
                }
            }
        }
    }
    
    public override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        setupBorders()
        
        children.filter { $0.name?.hasPrefix("sensor.") == true }.forEach {
            $0.removeFromParent()
        }
    }
}

// MARK: - Send and Spawn functions
extension PhysicsScene {
    private func sendParcel(
        side: EdgeSide,
        node: SKNode,
        entity: GameEntity
    ) {
        if entity.getReceived() {
            // TODO: Chamar função para acionar a ação do item
            entityManager?.remove(entity: entity)
            return
        }
        
        entityManager?.remove(entity: entity)
        var payload: PhysicsObjectData? = nil
        
        let xDirection: CGFloat = node.position.x
        //        switch side {
        //        case .top:
        //            xDirection = node.position.x
        //        case .right, .left:
        //            let dxFromCenter = node.position.x - frame.midX
        //            xDirection = -dxFromCenter
        //        }
        
        let objectType: PhysicsObjectType?
        
        switch entity {
        case is Ball:
            objectType = .ball
        default:
            objectType = nil
            print("erro: entity type not found")
        }
        
        guard let objectType else { return }
        
        payload = PhysicsObjectData(
            objectType: objectType,
            x: xDirection,
            y: node.position.y,
            side: side
        )
        
        if let physicsData = payload {
            let packet = GamePacket(type: .spawnPhysicsObject, physicsData: physicsData)
            matchManager.sendPacket(packet, mode: .reliable)
        } else {
            print("AVISO: Entidade do tipo \(type(of: entity)) saiu da tela, mas não há lógica de rede para ela.")
        }
    }
    
    private func getItemType(entity: PhysicsObjectType) -> GameEntity {
        switch entity {
        case .ball:
            return Ball()
        }
    }
    
    // Cria a entidade inicial
    func spawnBall(entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        let point: CGPoint = .init(x: frame.midX, y: frame.midY)
        value.setPosition(to: point)
        entityManager?.add(entity: value)
    }
    
    // Cria uma entidade em uma posição específica
    func spawnBall(at point: CGPoint, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        value.setPosition(to: point)
        entityManager?.add(entity: value)
    }
    
    // Cria uma entidade em movimento
    func spawnBall(at point: CGPoint, goingTo side: EdgeSide, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        value.setPosition(to: point)
        value.setReceived(value: true)
        entityManager?.add(entity: value)
        
        value.body?.applyForce(.init(dx: 0, dy: -25000))
        //        switch side {
        //        case .top:
        //            ball.body?.applyForce(.init(dx: 0, dy: -25000))
        //        case .left, .right:
        //            let direction: CGFloat = side == .right ? 1 : -1
        //            ball.body?.applyForce(.init(dx: 2000 * direction, dy: 0))
        //        }
    }
}

// MARK: - Parcel movement
extension PhysicsScene {
    private func handleMovementUpdate() {
        guard
            let manager = entityManager,
            let entity = currentDrag,
            let node = manager.node(for: entity),
            let body = node.physicsBody,
            let target = targetPoint
        else { return }
        
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
    
    private func exitSide(for node: SKNode, minExitVelocity velocity: CGFloat = 1) -> EdgeSide? {
        guard let body = node.physicsBody else { return nil }
        
        let accFrame = node.calculateAccumulatedFrame()
        
        if accFrame.minY > frame.maxY - 20, body.velocity.dy > velocity {
            return .top
        }
        
        //        if accFrame.maxX < frame.minX + 20, body.velocity.dx < -velocity {
        //            return .left
        //        }
        //
        //        if accFrame.minX > frame.maxX - 20, body.velocity.dx > velocity {
        //            return .right
        //        }
        
        return nil
    }
}
