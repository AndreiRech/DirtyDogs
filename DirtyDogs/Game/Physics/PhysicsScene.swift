//
//  PhysicsScene.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SpriteKit
import GameplayKit
import GameKit

public class PhysicsScene: SKScene {
    private var matchManager: MatchManager
    private var entityManager: EntityManager?
    weak var inventoryDelegate: InventoryDelegate?
    
    private var touchStartTime: TimeInterval = 0
    private var touchStartLocation: CGPoint = .zero


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

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.edge
        
        self.entityManager = EntityManager(scene: self)
        
        spawnBall()
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
        
        touchStartTime = CACurrentMediaTime()
        touchStartLocation = touch.location(in: self)
        
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
//        endDrag()
        guard let touch = touches.first,
              let manager = entityManager
        else { return }

        let location = touch.location(in: self)
        let dt = CACurrentMediaTime() - touchStartTime
        let dist = hypot(
            location.x - touchStartLocation.x,
            location.y - touchStartLocation.y
        )
        
        let isTap = dt < 0.20 && dist < 20

        if isTap {
            handleTap(at: location)
            return
        }

        // Drag normal
        endDrag()
    }
    
    private func handleTap(at location: CGPoint) {
        guard let manager = entityManager else { return }

        if let entity = manager.entity(at: location) {
            manager.remove(entity: entity)

            let item = InventoryItem(imageName: "ball_icon")
            inventoryDelegate?.didCollect(item: item)
        }
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
                    print("Bola saiu pelo lado \(side)")
                    sendParcel(side: side, node: node, entity: entity)
                }
            }
        }
    }

    public override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.edge
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
        entity: GKEntity
    ) {
        entityManager?.remove(entity: entity)
        let dxFromCenter = node.position.x - frame.midX
        let mirroredDx = -dxFromCenter

        let ballPayload = BallData(
            x: mirroredDx,
            y: node.position.y,
            side: side
        )
        
        do {
            let data = try JSONEncoder().encode(ballPayload)
            matchManager.sendData(data, mode: .reliable)
        } catch {
            print("Erro ao codificar e enviar 'BallData': \(error)")
        }
    }

    // Cria a bola inicial
    func spawnBall() {
        let ball = Ball()
        let point: CGPoint = .init(x: frame.midX, y: frame.midY)
        ball.setPosition(to: point)
        entityManager?.add(entity: ball)
    }
    
    // Cria uma bola em uma posição específica
    func spawnBall(at point: CGPoint) {
        let ball = Ball()
        ball.setPosition(to: point)
        entityManager?.add(entity: ball)
    }
    
    // Cria uma bola em movimento
    func spawnBall(at point: CGPoint, goingTo side: EdgeSide) {
        let ball = Ball()
        ball.setPosition(to: point)
        entityManager?.add(entity: ball)
        
        let direction: CGFloat = side == .right ? 1 : -1
        ball.body?.applyForce(.init(dx: 7500 * direction, dy: 0))
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
        
        if accFrame.maxX < frame.minX + 20, body.velocity.dx < -velocity {
            return .left
        }
        
        if accFrame.minX > frame.maxX - 20, body.velocity.dx > velocity {
            return .right
        }
        
        return nil
    }
}
