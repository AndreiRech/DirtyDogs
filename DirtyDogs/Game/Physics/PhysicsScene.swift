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
    var entityManager: EntityManager?
    
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
    
    //Stun
    private var isStunned = false
    private var stunOverlay: SKShapeNode?
    
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
        if isStunned { return }
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
        if isStunned { return }
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
                    print("Bola saiu pelo lado \(side)")
                    sendParcel(side: side, node: node, entity: entity)
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
        entity: GKEntity
    ) {
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
        case is Bomb:
            objectType = .bomb
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
        case .bomb:
            return Bomb()
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
    
    //Bomb functions:
    @discardableResult
    func spawnBomb(at point: CGPoint, goingTo side: EdgeSide) -> Bomb {
        let bomb = Bomb()
        bomb.setPosition(to: point)
        entityManager?.add(entity: bomb)

        // Força inicial
        bomb.body?.applyForce(.init(dx: 0, dy: -25000))

        return bomb
    }
    
    func spawnBomb() {
           let bomb = Bomb()
           let point: CGPoint = .init(x: frame.midX, y: frame.midY)
           bomb.setPosition(to: point)
           entityManager?.add(entity: bomb)
       }

    func spawnBomb(at point: CGPoint) {
        let bomb = Bomb()
        bomb.setPosition(to: point)
        entityManager?.add(entity: bomb)
    }

    func applyStun(duration: TimeInterval) {
            guard !isStunned else { return }
            isStunned = true
               // Overlay escuro por cima da tela
            let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 1.3,
                                                        height: size.height * 1.3),
                                         cornerRadius: 0)
            overlay.fillColor = UIColor.black.withAlphaComponent(0.35)
            overlay.strokeColor = .clear
            overlay.position = CGPoint(x: frame.midX, y: frame.midY)
            overlay.zPosition = 1000

            addChild(overlay)
            stunOverlay = overlay

            let wait = SKAction.wait(forDuration: duration)
            run(wait) { [weak self] in
                guard let self else { return }
                self.stunOverlay?.removeFromParent()
                self.stunOverlay = nil
                self.isStunned = false
            }
    }
       
    func explode(node: SKNode, entity: GKEntity?) {
            guard let parent = node.parent else { return }
            let origin = node.position

               // 1) Partículas de explosão
               let emitter = SKEmitterNode()
               emitter.particleTexture = nil                // bolinhas simples
               emitter.particleColor = .orange
               emitter.particleColorBlendFactor = 1.0
               emitter.numParticlesToEmit = 80
               emitter.particleBirthRate = 300
               emitter.particleLifetime = 0.4
               emitter.particleLifetimeRange = 0.1
               emitter.emissionAngleRange = .pi * 2
               emitter.particleSpeed = 320
               emitter.particleSpeedRange = 120
               emitter.particleAlpha = 0.9
               emitter.particleAlphaRange = 0.1
               emitter.particleAlphaSpeed = -2.0
               emitter.particleScale = 0.22
               emitter.particleScaleRange = 0.10
               emitter.particleScaleSpeed = -0.6
               emitter.particlePositionRange = CGVector(dx: 5, dy: 5)
               emitter.particleRotationRange = .pi * 2

               emitter.position = origin
               emitter.zPosition = 998
               parent.addChild(emitter)

               emitter.run(.sequence([
                   .wait(forDuration: 0.5),
                   .removeFromParent()
               ]))

               // Flash circular rápido
               let explosionCircle = SKShapeNode(circleOfRadius: 10)
               explosionCircle.fillColor = .orange
               explosionCircle.strokeColor = .yellow
               explosionCircle.lineWidth = 4
               explosionCircle.position = origin
               explosionCircle.zPosition = 999
               parent.addChild(explosionCircle)

               let expand = SKAction.scale(to: 5.0, duration: 0.20)
               let fade = SKAction.fadeOut(withDuration: 0.20)
               let group = SKAction.group([expand, fade])
               let removeCircle = SKAction.removeFromParent()
               explosionCircle.run(.sequence([group, removeCircle]))


               // Tremor de tela
               shake(intensity: 18, duration: 0.35)

               // Explosão física empurrando outros corpos
               applyBlast(from: origin, radius: 260, strength: 2200)

               // Stun no jogador local
               applyStun(duration: 1.0)

               // Remover a bomba em si
               if let entity {
                   entityManager?.remove(entity: entity)
               } else {
                   node.removeFromParent()
               }
           }

    // Empurra outros objetos com impulso radial
    func applyBlast(from origin: CGPoint, radius: CGFloat, strength: CGFloat) {
        guard let entities = entityManager?.getEntities() else { return }

           for entity in entities {
            guard let node = entity.component(ofType: GKSKNodeComponent.self)?.node,
                    let body = node.physicsBody else { continue }

                let dx = node.position.x - origin.x
                let dy = node.position.y - origin.y
                let distance = sqrt(dx*dx + dy*dy)
                if distance == 0 || distance > radius { continue }

                let nx = dx / distance
                let ny = dy / distance
                let falloff = (1.0 - distance / radius) // mais forte se estiver perto
                let impulseMag = falloff * strength

                let impulse = CGVector(dx: nx * impulseMag, dy: ny * impulseMag)
                body.applyImpulse(impulse)
            }
       }
       
    func shake(intensity: CGFloat = 15, duration: TimeInterval = 0.35) {
        let amplitudeX = intensity
        let amplitudeY = intensity
            
        let numberOfShakes = Int(duration / 0.015)
        var actions: [SKAction] = []
             
        for _ in 0..<numberOfShakes {
            let dx = CGFloat.random(in: -amplitudeX...amplitudeX)
            let dy = CGFloat.random(in: -amplitudeY...amplitudeY)
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.015)
            let reverse = move.reversed()
            actions.append(move)
            actions.append(reverse)
        }
             
        run(SKAction.sequence(actions))
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
