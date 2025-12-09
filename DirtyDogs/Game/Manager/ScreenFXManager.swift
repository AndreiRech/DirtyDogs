//
//  ScreenFXManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 21/11/25.
//

import SpriteKit
import GameplayKit

class ScreenFXManager {
    weak var scene: GameScene?
    weak var entityManager: EntityManager?
    private let haptics: HapticsServiceProtocol
    private var motionService: MotionServiceProtocol
    
    private var stunOverlay: SKNode?
    var isStunned: Bool = false
    
    init(scene: GameScene, entityManager: EntityManager?, hapticsService: HapticsServiceProtocol) {
        self.scene = scene
        self.entityManager = entityManager
        self.haptics = hapticsService
        haptics.prepareHaptics()
        motionService = MotionService()
    }
    
    func playHaptics(with sound: SoundEffect) {
        switch sound {
        case .itemFound:
            haptics.findItem()
        case .success:
            haptics.complexSuccess()
        case .bombExploded:
            haptics.explosionBomb()
        case .poopSplash:
            haptics.cleanScreen()
        case .gridTouch:
            haptics.feedbackGenerator(.medium)
        }
    }
    
    func applyStun(duration: TimeInterval, showOverlay: Bool = false) {
        guard let scene = scene, !isStunned else { return }
        isStunned = true
        
        // Bloqueia a UI
        scene.uiDelegate?.isOverAll(true)
        
        // Desabilita interações na scene
        scene.isUserInteractionEnabled = false
        
        if showOverlay {
            // Container para o efeito de blur
            let blurContainer = SKNode()
            
            let currentMaxZ = scene.children.map { $0.zPosition }.max() ?? 0
            blurContainer.zPosition = currentMaxZ + 10
            blurContainer.name = "stunOverlay"
            
            // Cria múltiplas camadas para simular blur
            let overlaySize = CGSize(width: scene.size.width * 1.5, height: scene.size.height * 1.5)
            let overlayPosition = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            
            // Camada base (mais opaca)
            let baseOverlay = SKSpriteNode(color: UIColor.white.withAlphaComponent(0.5),
                                           size: overlaySize)
            baseOverlay.position = overlayPosition
            baseOverlay.alpha = 0
            baseOverlay.zPosition = blurContainer.zPosition + 1
            
            blurContainer.addChild(baseOverlay)
            
            // Camadas adicionais deslocadas para criar efeito de blur
            let blurLayers = 8
            for i in 1...blurLayers {
                let offset = CGFloat(i) * 2.5
                let alpha = 0.15 / CGFloat(i)
                
                // Cria 4 camadas por "anel" (cima, baixo, esquerda, direita)
                let positions = [
                    CGPoint(x: overlayPosition.x + offset, y: overlayPosition.y),
                    CGPoint(x: overlayPosition.x - offset, y: overlayPosition.y),
                    CGPoint(x: overlayPosition.x, y: overlayPosition.y + offset),
                    CGPoint(x: overlayPosition.x, y: overlayPosition.y - offset)
                ]
                
                for pos in positions {
                    let layer = SKSpriteNode(color: UIColor.white.withAlphaComponent(alpha),
                                            size: overlaySize)
                    layer.position = pos
                    layer.alpha = 0
                    layer.zPosition = 3001
                    blurContainer.addChild(layer)
                }
            }
            
            scene.addChild(blurContainer)
            
            // Anima todas as camadas
            blurContainer.children.forEach { child in
                child.run(.fadeAlpha(to: 1.0, duration: 0.2))
            }
            
            self.stunOverlay = blurContainer
        } else {
            self.stunOverlay = nil
        }

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            self?.removeStun()
        }
    }
    
    func removeStun() {
        guard let scene = scene else { return }
        
        stunOverlay?.run(.sequence([
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
        stunOverlay = nil
        isStunned = false
        
        // Reabilita interações na scene
        scene.isUserInteractionEnabled = true
        
        // Desbloqueia a UI
        scene.uiDelegate?.isOverAll(false)
    }
    
    func explode(node: SKNode, entity: GKEntity?) {
        guard let scene = scene, let parent = node.parent else { return }
        
        AudioService.shared.play(sound: "Explosion.wav", volume: 0.4)
        
        let origin = node.position

        let emitter = SKEmitterNode()
        emitter.particleTexture = nil
        emitter.particleColor = .orange
        emitter.particleColorBlendFactor = 1.0
        emitter.numParticlesToEmit = 200
        emitter.particleBirthRate = 800
        emitter.particleLifetime = 0.4
        emitter.particleSpeed = 520
        emitter.particleAlpha = 0.9
        emitter.particleScale = 0.40
        emitter.position = origin
        emitter.zPosition = 998
        parent.addChild(emitter)

        emitter.run(.sequence([.wait(forDuration: 0.5), .removeFromParent()]))

        let explosionCircle = SKShapeNode(circleOfRadius: 120)
        explosionCircle.fillColor = .orange
        explosionCircle.strokeColor = .yellow
        explosionCircle.lineWidth = 22
        explosionCircle.alpha = 0.85
        explosionCircle.position = origin
        explosionCircle.zPosition = 999
        parent.addChild(explosionCircle)

        explosionCircle.run(.sequence([
            .group([.scale(to: 4.0, duration: 0.30), .fadeOut(withDuration: 0.25)]),
            .removeFromParent()
        ]))

        shake(intensity: 18, duration: 0.35)
        applyBlast(from: origin, radius: 260, strength: 2200)
        playHaptics(with: .bombExploded)
        
        // Aplica o stun ANTES de remover a entidade
        applyStun(duration: 1.0, showOverlay: true)
        
        // Agenda a remoção da entidade após o stun
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1.0))
            if let entity = entity {
                self?.entityManager?.remove(entity: entity)
            } else {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: Tint
    
    func explodeTint(node: SKNode, entity: GKEntity?) {
        guard let scene = scene, let parent = node.parent else { return }
        
        AudioService.shared.play(sound: "Spray.wav", volume: -0.5)
        
        let origin = node.position
        
        let poopEmitter = SKEmitterNode()
        poopEmitter.particleTexture = nil
        poopEmitter.particleColor = UIColor(red: 0.32, green: 0.17, blue: 0.06, alpha: 1.0)
        poopEmitter.numParticlesToEmit = 180
        poopEmitter.particleBirthRate = 900
        poopEmitter.particleLifetime = 0.8
        poopEmitter.particleSpeed = 460
        poopEmitter.particleScale = 0.55
        poopEmitter.position = origin
        poopEmitter.zPosition = 998
        parent.addChild(poopEmitter)
        poopEmitter.run(.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
        
        let poopFlash = SKShapeNode(circleOfRadius: 130)
        poopFlash.fillColor = UIColor(red: 0.8, green: 0.65, blue: 0.3, alpha: 1.0)
        poopFlash.strokeColor = .brown
        poopFlash.lineWidth = 22
        poopFlash.position = origin
        poopFlash.zPosition = 999
        parent.addChild(poopFlash)
        poopFlash.run(.sequence([
            .group([.scale(to: 3.8, duration: 0.25), .fadeOut(withDuration: 0.25)]),
            .removeFromParent()
        ]))
        
        let poopOverlay = SKSpriteNode(color: UIColor(red: 0.22, green: 0.12, blue: 0.03, alpha: 1.0),
                                       size: CGSize(width: scene.size.width * 2.5, height: scene.size.height * 2.5))
        poopOverlay.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        poopOverlay.zPosition = 2000
        poopOverlay.alpha = 0
        poopOverlay.name = "poopOverlay"
        scene.addChild(poopOverlay)
        
        poopOverlay.run(.sequence([
            .fadeAlpha(to: 1.00, duration: 0.25),
        ]))
        
        shake(intensity: 25, duration: 0.45)
        playHaptics(with: .poopSplash)
        applyBlast(from: origin, radius: 350, strength: 5000)
        applyStun(duration: 1.5, showOverlay: false)
        
        // Agenda a remoção da entidade após o stun
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            if let entity = entity {
                self?.entityManager?.remove(entity: entity)
            } else {
                node.removeFromParent()
            }
        }
        
        var shakeCountIntensity = 0.0
        motionService.startMonitoring { [weak self] intensity in
            shakeCountIntensity += intensity
            if shakeCountIntensity >= 20.0 {
                self?.motionService.stopMonitoring()
                self?.cleanPoopOverlayOnShake()
            }
        }
    }
    
    private func applyBlast(from origin: CGPoint, radius: CGFloat, strength: CGFloat) {
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
    
    func shake(intensity: CGFloat, duration: TimeInterval) {
        guard let scene = scene else { return }
        let numberOfShakes = Int(duration / 0.015)
        var actions: [SKAction] = []
        
        for _ in 0..<numberOfShakes {
            let dx = CGFloat.random(in: -intensity...intensity)
            let dy = CGFloat.random(in: -intensity...intensity)
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.015)
            actions.append(move)
            actions.append(move.reversed())
        }
        scene.run(.sequence(actions))
    }
    
    func cleanPoopOverlayOnShake() {
        guard let scene = scene else { return }

        playHaptics(with: .poopSplash)
        
        let overlays = scene.children.filter { $0.name == "poopOverlay" }
        
        for overlay in overlays {
            overlay.run(.sequence([
                .fadeOut(withDuration: 1.9),
                .removeFromParent()
            ]))
        }
        
        // Remove o stun quando limpar o overlay
        removeStun()
    }
    
    // MARK: Seeds
    
    func explodeSeed(node: SKNode, entity: GKEntity?, gridManager: GridManager?) {
        guard let parent = node.parent else { return }
        let origin = node.position
        
        let seedEmitter = SKEmitterNode()
        seedEmitter.particleTexture = nil
        seedEmitter.particleColor = .systemPink
        seedEmitter.particleColorBlendFactor = 1.0
        seedEmitter.particleColorSequence = nil
        seedEmitter.particleColorBlendFactorSequence = nil
        
        let colorSequence = SKKeyframeSequence(keyframeValues: [
            UIColor.systemPink,
            UIColor.systemGreen,
            UIColor.systemPink.withAlphaComponent(0.3)
        ], times: [0, 0.5, 1])
        seedEmitter.particleColorSequence = colorSequence
        
        seedEmitter.numParticlesToEmit = 200
        seedEmitter.particleBirthRate = 1000
        seedEmitter.particleLifetime = 0.8
        seedEmitter.particleLifetimeRange = 0.3
        seedEmitter.particleSpeed = 450
        seedEmitter.particleSpeedRange = 150
        seedEmitter.emissionAngleRange = .pi * 2
        seedEmitter.particleAlpha = 1.0
        seedEmitter.particleAlphaSpeed = -1.2
        seedEmitter.particleScale = 0.4
        seedEmitter.particleScaleRange = 0.2
        seedEmitter.particleScaleSpeed = -0.3
        seedEmitter.position = origin
        seedEmitter.zPosition = 998
        parent.addChild(seedEmitter)
        
        seedEmitter.run(.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
        
        createImpactWaves(at: origin, in: parent)
        
        let seedFlash = SKShapeNode(circleOfRadius: 80)
        seedFlash.fillColor = .systemPink.withAlphaComponent(0.6)
        seedFlash.strokeColor = .systemGreen
        seedFlash.lineWidth = 20
        seedFlash.glowWidth = 8
        seedFlash.alpha = 1.0
        seedFlash.position = origin
        seedFlash.zPosition = 999
        parent.addChild(seedFlash)
        
        seedFlash.run(.sequence([
            .group([
                .scale(to: 4.0, duration: 0.35),
                .fadeOut(withDuration: 0.3)
            ]),
            .removeFromParent()
        ]))
        
        if let gridManager = gridManager {
            animatePlanting(gridManager: gridManager)
        }
        
        shake(intensity: 15, duration: 0.3)
        haptics.explosionBomb()
        haptics.complexSuccess()
        applyStun(duration: 0.8, showOverlay: false)
        
        // Agenda a remoção da entidade após o stun
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.8))
            if let entity = entity {
                self?.entityManager?.remove(entity: entity)
            } else {
                node.removeFromParent()
            }
        }
    }

    private func createImpactWaves(at position: CGPoint, in parent: SKNode) {
        AudioService.shared.play(sound: "Plantation.wav", volume: -0.5)
        for i in 0..<3 {
            let wave = SKShapeNode(circleOfRadius: 60)
            wave.strokeColor = i % 2 == 0 ? .systemPink : .systemGreen
            wave.lineWidth = 12 - CGFloat(i * 3)
            wave.fillColor = .clear
            wave.alpha = 0.8
            wave.position = position
            wave.zPosition = 997
            parent.addChild(wave)
            
            let delay = Double(i) * 0.1
            wave.run(.sequence([
                .wait(forDuration: delay),
                .group([
                    .scale(to: 3.5, duration: 0.5),
                    .fadeOut(withDuration: 0.5)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func animatePlanting(gridManager: GridManager) {
        guard let scene = scene else { return }
        
        let totalBlocks = gridManager.blocks.count
        let centerIndex = totalBlocks / 2
        var blockDistances: [(index: Int, distance: CGFloat)] = []
        
        for i in 0..<totalBlocks {
            let block = gridManager.blocks[i]
            if block.layer < 0 { continue }
            
            if let _ = gridManager.blockNodes.first(where: { $0.name == "block_\(i)" }) {
                let row = i / Int(sqrt(Double(totalBlocks)))
                let col = i % Int(sqrt(Double(totalBlocks)))
                let centerRow = centerIndex / Int(sqrt(Double(totalBlocks)))
                let centerCol = centerIndex % Int(sqrt(Double(totalBlocks)))
                let distance = sqrt(pow(CGFloat(row - centerRow), 2) + pow(CGFloat(col - centerCol), 2))
                
                blockDistances.append((i, distance))
            }
        }
        
        blockDistances.sort { $0.distance < $1.distance }
        
        for (index, item) in blockDistances.enumerated() {
            let i = item.index
            let block = gridManager.blocks[i]
            
            if let blockNode = gridManager.blockNodes.first(where: { $0.name == "block_\(i)" }) {
                let blockPosition = scene.convert(blockNode.position, from: gridManager.gridContainer)
               
                let texture = SKTexture(imageNamed: "Seed")
                let seedItem = SKSpriteNode(texture: texture)
                seedItem.size = CGSize(width: 70, height: 70)
                seedItem.alpha = 0
                seedItem.position = CGPoint(x: blockPosition.x, y: blockPosition.y + 100)
                seedItem.zPosition = 2000
                scene.addChild(seedItem)
                
                let trail = SKEmitterNode()
                trail.particleTexture = nil
                trail.particleColor = .systemGreen
                trail.particleColorBlendFactor = 1.0
                trail.numParticlesToEmit = 0
                trail.particleBirthRate = 80
                trail.particleLifetime = 0.3
                trail.particleSpeed = 0
                trail.particleAlpha = 0.6
                trail.particleScale = 0.2
                trail.particleScaleSpeed = -0.4
                trail.zPosition = 1999
                seedItem.addChild(trail)
                
                let delay = Double(index) * 0.04
                
                let moveDown = SKAction.moveTo(y: blockPosition.y, duration: 0.35)
                moveDown.timingMode = .easeIn
                let fadeIn = SKAction.fadeIn(withDuration: 0.1)
                let fallGroup = SKAction.group([fadeIn, moveDown])
                
                let bounceUp = SKAction.moveTo(y: blockPosition.y + 15, duration: 0.08)
                let bounceDown = SKAction.moveTo(y: blockPosition.y, duration: 0.08)
                let bounce = SKAction.sequence([bounceUp, bounceDown])
                
                let scaleUp = SKAction.scale(to: 1.4, duration: 0.12)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.12)
                let pulse = SKAction.sequence([scaleUp, scaleDown])
                
                let colorize = SKAction.sequence([
                    SKAction.colorize(with: .white, colorBlendFactor: 0.6, duration: 0.12),
                    SKAction.colorize(withColorBlendFactor: 0, duration: 0.12)
                ])
                let pulseGroup = SKAction.group([pulse, colorize])
                
                let disappear = SKAction.group([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.scale(to: 0.3, duration: 0.2),
                    SKAction.moveTo(y: blockPosition.y - 10, duration: 0.2)
                ])
                
                seedItem.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    fallGroup,
                    bounce,
                    pulseGroup,
                    SKAction.wait(forDuration: 0.15),
                    disappear,
                    SKAction.run { trail.particleBirthRate = 0 },
                    SKAction.removeFromParent()
                ]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.35) {
                    self.createGroundImpact(at: blockPosition, in: scene)
                }
                
                let elasticWiggle = SKAction.customAction(withDuration: 0.5) { node, elapsedTime in
                    let progress = elapsedTime / 0.5
                    let angle = sin(progress * .pi * 4) * 0.08 * (1 - progress)
                    node.zRotation = angle
                }
                
                let squashStretch = SKAction.sequence([
                    .group([
                        .scaleX(to: 1.15, duration: 0.08),
                        .scaleY(to: 0.85, duration: 0.08)
                    ]),
                    .group([
                        .scaleX(to: 0.95, duration: 0.12),
                        .scaleY(to: 1.05, duration: 0.12)
                    ]),
                    .group([
                        .scaleX(to: 1.0, duration: 0.1),
                        .scaleY(to: 1.0, duration: 0.1)
                    ])
                ])
                
                blockNode.run(.sequence([
                    .wait(forDuration: delay + 0.35),
                    .group([elasticWiggle, squashStretch])
                ]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.8) {
                    let newLayer: Int
                    
                    if block.layer == 3 {
                        newLayer = 2
                    } else {
                        newLayer = max(block.layer - 1, 0)
                    }
                    
                    gridManager.updateBlockLayer(at: i, to: newLayer)
                    self.createBlockShine(on: blockNode)
                }
            }
        }
    }

    private func createGroundImpact(at position: CGPoint, in parent: SKNode) {
        let impact = SKEmitterNode()
        impact.particleTexture = nil
        impact.particleColor = .systemGreen
        impact.particleColorBlendFactor = 1.0
        impact.numParticlesToEmit = 15
        impact.particleBirthRate = 300
        impact.particleLifetime = 0.3
        impact.particleSpeed = 80
        impact.particleSpeedRange = 40
        impact.emissionAngle = -.pi / 2
        impact.emissionAngleRange = .pi / 3
        impact.particleAlpha = 0.7
        impact.particleScale = 0.25
        impact.particleScaleSpeed = -0.5
        impact.position = position
        impact.zPosition = 1998
        parent.addChild(impact)
        
        impact.run(.sequence([.wait(forDuration: 0.5), .removeFromParent()]))
        
        let groundWave = SKShapeNode(circleOfRadius: 20)
        groundWave.strokeColor = .systemGreen.withAlphaComponent(0.6)
        groundWave.lineWidth = 4
        groundWave.fillColor = .clear
        groundWave.position = position
        groundWave.zPosition = 1997
        parent.addChild(groundWave)
        
        groundWave.run(.sequence([
            .group([
                .scale(to: 2.0, duration: 0.25),
                .fadeOut(withDuration: 0.25)
            ]),
            .removeFromParent()
        ]))
    }

    private func createBlockShine(on blockNode: SKNode) {
        let shine = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 5)
        shine.fillColor = .clear
        shine.strokeColor = .clear
        shine.alpha = 0
        shine.position = .zero
        shine.zPosition = 10
        blockNode.addChild(shine)
        
        shine.run(.sequence([
            .fadeAlpha(to: 0.5, duration: 0.1),
            .fadeOut(withDuration: 0.2),
            .removeFromParent()
        ]))
    }
    
    func shakeSquare(node: SKNode) {
        let moveLeft = SKAction.moveBy(x: -4, y: 0, duration: 0.04)
        let moveRight = SKAction.moveBy(x: 8, y: 0, duration: 0.04)
        let moveCenter = SKAction.moveBy(x: -4, y: 0, duration: 0.04)

        let sequence = SKAction.sequence([moveLeft, moveRight, moveCenter])
        node.run(sequence)
    }
}

