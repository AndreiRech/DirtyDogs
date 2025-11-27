//
//  ScreenFXManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 21/11/25.
//

import SpriteKit
import GameplayKit

class ScreenFXManager {
    weak var scene: SKScene?
    weak var entityManager: EntityManager?
    private let haptics = HapticsService()
    
    private var stunOverlay: SKShapeNode?
    var isStunned: Bool = false
    
    init(scene: SKScene, entityManager: EntityManager?) {
        self.scene = scene
        self.entityManager = entityManager
        haptics.prepareHaptics()
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
            haptics.cleanScreen() // TODO: Alterar para o do coco
        }
    }
    
    func applyStun(duration: TimeInterval) {
        guard let scene = scene, !isStunned else { return }
        isStunned = true
        
        let overlay = SKShapeNode(rectOf: CGSize(width: scene.size.width * 1.3, height: scene.size.height * 1.3), cornerRadius: 0)
        overlay.fillColor = UIColor.black.withAlphaComponent(0.35)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        overlay.zPosition = 1000
        overlay.name = "stunOverlay"
        
        scene.addChild(overlay)
        self.stunOverlay = overlay
        
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            self?.removeStun()
        }
    }
    
    func removeStun() {
        stunOverlay?.removeFromParent()
        stunOverlay = nil
        isStunned = false
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
        applyStun(duration: 1.0)
        playHaptics(with: .bombExploded)
        
        if let entity = entity {
            entityManager?.remove(entity: entity)
        } else {
            node.removeFromParent()
        }
    }
    
    func explodePoop(node: SKNode, entity: GKEntity?) {
        guard let scene = scene, let parent = node.parent else { return }
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
            .fadeAlpha(to: 0.95, duration: 0.25),
            .wait(forDuration: 5.0),
            .fadeOut(withDuration: 0.7),
            .removeFromParent()
        ]))
        
        shake(intensity: 25, duration: 0.45)
        playHaptics(with: .poopSplash)
        applyBlast(from: origin, radius: 350, strength: 5000)
        applyStun(duration: 1.5)
        
        if let entity = entity {
            entityManager?.remove(entity: entity)
        } else {
            node.removeFromParent()
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
    }
    
    func explodeSeed(node: SKNode, entity: GKEntity?, gridManager: GridManager?) {
            guard let parent = node.parent else { return }
            let origin = node.position
            
            // Emitter de partículas rosa/verde (semente)
            let seedEmitter = SKEmitterNode()
            seedEmitter.particleTexture = nil
            seedEmitter.particleColor = .systemPink
            seedEmitter.particleColorBlendFactor = 1.0
            seedEmitter.numParticlesToEmit = 150
            seedEmitter.particleBirthRate = 800
            seedEmitter.particleLifetime = 0.6
            seedEmitter.particleSpeed = 400
            seedEmitter.particleAlpha = 0.9
            seedEmitter.particleScale = 0.35
            seedEmitter.position = origin
            seedEmitter.zPosition = 998
            parent.addChild(seedEmitter)
            
            seedEmitter.run(.sequence([.wait(forDuration: 0.8), .removeFromParent()]))
            
            // Flash rosa
            let seedFlash = SKShapeNode(circleOfRadius: 100)
            seedFlash.fillColor = .systemPink
            seedFlash.strokeColor = .systemGreen
            seedFlash.lineWidth = 18
            seedFlash.alpha = 0.8
            seedFlash.position = origin
            seedFlash.zPosition = 999
            parent.addChild(seedFlash)
            
            seedFlash.run(.sequence([
                .group([.scale(to: 3.5, duration: 0.28), .fadeOut(withDuration: 0.25)]),
                .removeFromParent()
            ]))
            
            // Animação de "plantio" - bolinhas nos blocos do grid
            if let gridManager = gridManager {
                animatePlanting(gridManager: gridManager)
            }
            
            shake(intensity: 15, duration: 0.3)
            haptics.explosionBomb()
            haptics.complexSuccess()
            applyStun(duration: 0.8)
            
            if let entity = entity {
                entityManager?.remove(entity: entity)
            } else {
                node.removeFromParent()
            }
        }
        
        private func animatePlanting(gridManager: GridManager) {
            guard let scene = scene else { return }
            
            let totalBlocks = gridManager.blocks.count
            
            for i in 0..<totalBlocks {
                let block = gridManager.blocks[i]
                
                // Se já está no nível mínimo (grama = layer 0), não faz nada
                if block.layer < 0 { continue }
                
                // Pega a posição do bloco
                if let blockNode = gridManager.blockNodes.first(where: { $0.name == "block_\(i)" }) {
                    let blockPosition = scene.convert(blockNode.position, from: gridManager.gridContainer)
                    
                    // Cria a bolinha de "plantio"
                    let seedBall = SKShapeNode(circleOfRadius: 20)
                    seedBall.fillColor = .systemPink
                    seedBall.strokeColor = .systemGreen
                    seedBall.lineWidth = 3
                    seedBall.alpha = 0
                    seedBall.position = blockPosition
                    seedBall.zPosition = 2000 // Bem acima de tudo
                    scene.addChild(seedBall)
                    
                    // Animação: aparece, pulsa e desaparece
                    let delay = Double(i) * 0.08 
                    
                    seedBall.run(.sequence([
                        .wait(forDuration: delay),
                        .group([
                            .fadeIn(withDuration: 0.15),
                            .scale(to: 1.2, duration: 0.15)
                        ]),
                        .wait(forDuration: 0.1),
                        .group([
                            .fadeOut(withDuration: 0.15),
                            .scale(to: 0.8, duration: 0.15)
                        ]),
                        .removeFromParent()
                    ]))
                    
                    // Animaçao pra mexer os quadradinhos
                    let wiggleLeft = SKAction.rotate(byAngle: .pi / 32, duration: 0.05)
                    let wiggleRight = SKAction.rotate(byAngle: -.pi / 32, duration: 0.05)
                    let wiggleSequence = SKAction.sequence([wiggleLeft, wiggleRight, wiggleRight, wiggleLeft])
                    let wiggleRepeat = SKAction.repeat(wiggleSequence, count: 2)

                    blockNode.run(.sequence([
                        .wait(forDuration: delay),
                        wiggleRepeat
                    ]))
                    
                    // Atualiza o layer do bloco após a animação
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.3) {
                        let newLayer: Int

                        // Se finalizado (camada 3), volta para pedra (2)
                        if block.layer == 3 {
                            newLayer = 2
                        }
                        // Caso normal: diminui a camada (inclui a camada 0 também, se quiser)
                        else {
                            newLayer = max(block.layer - 1, 0)
                        }

                        gridManager.updateBlockLayer(at: i, to: newLayer)
                    }
                }
            }
        }
}
