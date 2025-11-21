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
    
    let haptics = HapticsService()
    
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
        self.backgroundColor = .systemGreen
        view.backgroundColor = .systemGreen
        
        scaleMode = .resizeFill
        physicsWorld.gravity = .init(dx: 0, dy: -9.8)
        
        setupBorders()
        
        self.entityManager = EntityManager(scene: self)
        
        haptics.prepareHaptics()
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
            entityManager?.remove(entity: entity)
            return
        }
        
        entityManager?.remove(entity: entity)
        var payload: PhysicsObjectData? = nil
        
        let xDirection: CGFloat = node.position.x
        
        let objectType: PhysicsObjectType?
        
        switch entity {
        case is Ball:
            objectType = .ball
        case is Bomb:
            objectType = .bomb
        case is Poop:
            objectType = .poop
        default:
            objectType = nil
            print("❌ erro: entity type not found")
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
            print("📤 Enviando objeto: \(objectType) na posição x:\(xDirection) y:\(node.position.y)")
        } else {
            print("⚠️ AVISO: Entidade do tipo \(type(of: entity)) saiu da tela, mas não há lógica de rede para ela.")
        }
    }
    
    private func getItemType(entity: PhysicsObjectType) -> GameEntity {
        switch entity {
        case .ball:
            return Ball()
        case .bomb:
            return Bomb()
        case .poop:
            return Poop()
        }
    }
    
    // ✅ CRIA ITEM LOCAL (você vai arrastar e enviar)
    func spawnBall(entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        let point: CGPoint = .init(x: frame.midX, y: frame.maxY - 100)
        value.setPosition(to: point)
        entityManager?.add(entity: value)
        print("🎾 Criada bolinha local na posição: \(point)")
        
        // ❌ NÃO executa ação aqui! Você vai arrastar primeiro
    }
    
    // ✅ CRIA ITEM RECEBIDO DA REDE (já executa a ação)
    func spawnItem(at point: CGPoint, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        value.setPosition(to: point)
        value.setReceived(value: true)  // ✅ Marca como recebido
        entityManager?.add(entity: value)
        print("📥 Recebido item da rede: \(entity) na posição: \(point)")
        
        // ✅ Agora SIM executa a ação (bomba explode, cocô suja)
//        executeAction(value: value)
    }
    
    // Cria uma entidade em movimento (recebida da rede) - LEGACY
    func spawnBall(at point: CGPoint, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        value.setPosition(to: point)
        value.setReceived(value: true)
        entityManager?.add(entity: value)
        
        value.body?.applyForce(.init(dx: 0, dy: -25000))
        print("📥 Recebida bolinha da rede na posição: \(point)")
    }
    
    //Bomb functions - LEGACY
    @discardableResult
    func spawnBomb(at point: CGPoint, goingTo side: EdgeSide) -> Bomb {
        let bomb = Bomb()
        bomb.setPosition(to: point)
        entityManager?.add(entity: bomb)
        
        bomb.body?.applyForce(.init(dx: 0, dy: -25000))
        
        return bomb
    }
    
    func spawnBomb() {
        let bomb = Bomb()
        let point: CGPoint = .init(x: frame.midX, y: frame.maxY - 100)
        bomb.setPosition(to: point)
        entityManager?.add(entity: bomb)
        print("💣 Criada bomba local na posição: \(point)")
    }
    
    func spawnBomb(at point: CGPoint) {
        let bomb = Bomb()
        bomb.setPosition(to: point)
        entityManager?.add(entity: bomb)
        print("💣 Criada bomba em posição específica: \(point)")
        
        // ❌ NÃO executa ação aqui se for local
    }
    
    // ✅ SÓ executa ações em itens RECEBIDOS
    func executeAction(value: GameEntity) {
        if let bomb = value as? Bomb {
            bomb.startFuseAnimation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if let node = bomb.node {
                    self.explode(node: node, entity: bomb)
                }
            }
        }
        
        if let poop = value as? Poop {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if let node = poop.node {
                    self.explodePoop(node: node, entity: poop)
                }
            }
        }
    }
    
    func applyStun(duration: TimeInterval) {
        guard !isStunned else { return }
        isStunned = true
        
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
        
        let emitter = SKEmitterNode()
        emitter.particleTexture = nil
        emitter.particleColor = .orange
        emitter.particleColorBlendFactor = 1.0
        emitter.numParticlesToEmit = 200
        emitter.particleBirthRate = 800
        emitter.particleLifetime = 0.4
        emitter.particleLifetimeRange = 0.1
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 520
        emitter.particleSpeedRange = 220
        emitter.particleAlpha = 0.9
        emitter.particleAlphaRange = 0.1
        emitter.particleAlphaSpeed = -2.0
        emitter.particleScale = 0.40
        emitter.particleScaleRange = 0.10
        emitter.particleScaleSpeed = -0.6
        emitter.particlePositionRange = CGVector(dx: 20, dy: 20)
        emitter.particleRotationRange = .pi * 2
        
        emitter.position = origin
        emitter.zPosition = 998
        parent.addChild(emitter)
        
        emitter.run(.sequence([
            .wait(forDuration: 0.5),
            .removeFromParent()
        ]))
        
        let explosionCircle = SKShapeNode(circleOfRadius: 120)
        explosionCircle.fillColor = .orange
        explosionCircle.strokeColor = .yellow
        explosionCircle.lineWidth = 22
        explosionCircle.alpha = 0.85
        explosionCircle.position = origin
        explosionCircle.zPosition = 999
        parent.addChild(explosionCircle)
        
        let expand = SKAction.scale(to: 4.0, duration: 0.30)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        let group = SKAction.group([expand, fade])
        let removeCircle = SKAction.removeFromParent()
        
        explosionCircle.run(.sequence([group, removeCircle]))
        
        shake(intensity: 18, duration: 0.35)
        applyBlast(from: origin, radius: 260, strength: 2200)
        applyStun(duration: 1.0)
        haptics.explosionBomb()
        
        if let entity {
            entityManager?.remove(entity: entity)
        } else {
            node.removeFromParent()
        }
    }
    
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
            let falloff = (1.0 - distance / radius)
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
    
    func explodePoop(node: SKNode, entity: GKEntity?) {
        guard let parent = node.parent else { return }
        let origin = node.position

        let poopEmitter = SKEmitterNode()
        poopEmitter.particleTexture = nil
        poopEmitter.particleColor = UIColor(red: 0.32, green: 0.17, blue: 0.06, alpha: 1.0)
        poopEmitter.particleColorBlendFactor = 1.0
        poopEmitter.numParticlesToEmit = 180
        poopEmitter.particleBirthRate = 900
        poopEmitter.particleLifetime = 0.8
        poopEmitter.particleSpeed = 460
        poopEmitter.particleSpeedRange = 260
        poopEmitter.particleScale = 0.55
        poopEmitter.particleScaleRange = 0.30
        poopEmitter.emissionAngleRange = .pi * 2
        poopEmitter.position = origin
        poopEmitter.zPosition = 998
        parent.addChild(poopEmitter)

        poopEmitter.run(.sequence([ .wait(forDuration: 1.0), .removeFromParent() ]))

        let poopFlash = SKShapeNode(circleOfRadius: 130)
        poopFlash.fillColor = UIColor(red: 0.8, green: 0.65, blue: 0.3, alpha: 1.0)
        poopFlash.strokeColor = .brown
        poopFlash.lineWidth = 22
        poopFlash.position = origin
        poopFlash.zPosition = 999
        parent.addChild(poopFlash)

        poopFlash.run(.sequence([
            .group([
                .scale(to: 3.8, duration: 0.25),
                .fadeOut(withDuration: 0.25)
            ]),
            .removeFromParent()
        ]))

        let poopOverlay = SKSpriteNode(color: UIColor(
            red: 0.22, green: 0.12, blue: 0.03, alpha: 1.0
        ), size: CGSize(width: size.width * 2.5, height: size.height * 2.5))

        poopOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        poopOverlay.zPosition = 2000
        poopOverlay.alpha = 0

        addChild(poopOverlay)

        let appear = SKAction.fadeAlpha(to: 0.95, duration: 0.25)
        let wait = SKAction.wait(forDuration: 5.0)
        let disappear = SKAction.fadeOut(withDuration: 0.7)
        let remove = SKAction.removeFromParent()

        poopOverlay.run(.sequence([appear, wait, disappear, remove]))

        shake(intensity: 25, duration: 0.45)
        haptics.explosionBomb()

        applyBlast(
            from: origin,
            radius: 350,
            strength: 5000
        )

        applyStun(duration: 1.5)

        if let entity {
            entityManager?.remove(entity: entity)
        } else {
            node.removeFromParent()
        }
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
        
        return nil
    }
}
