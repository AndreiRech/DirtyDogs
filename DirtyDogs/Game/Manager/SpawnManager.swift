//
//  SpawnManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 21/11/25.
//

import SpriteKit
import GameplayKit

class SpawnManager {
    weak var entityManager: EntityManager?
    weak var fxManager: ScreenFXManager?
    weak var gridManager: GridManager?
    
    private let audioBlowService: AudioBlowServiceProtocol
    private var activeBombs: [Bomb] = []
    
    init(entityManager: EntityManager?, fxManager: ScreenFXManager?, gridManager: GridManager? = nil) {
        self.entityManager = entityManager
        self.fxManager = fxManager
        self.gridManager = gridManager
        self.audioBlowService = AudioBlowService()
    }
    
    // Cria uma entidade em uma posição específica
    func spawnItem(at point: CGPoint, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        value.setPosition(to: point)
        entityManager?.add(entity: value)
    }
    
    // Cria uma entidade em movimento
    func spawnItem(at point: CGPoint, goingTo side: EdgeSide, entity: PhysicsObjectType) {
        let value = getItemType(entity: entity)
        
        value.setPosition(to: point)
        value.setReceived(value: true)
        entityManager?.add(entity: value)
        
        value.body?.applyForce(.init(dx: 0, dy: -30000))
        
        executeAction(value: value)
    }
    
    private func getItemType(entity: PhysicsObjectType) -> GameEntity {
        switch entity {
        case .ball:
            return Ball()
        case .bomb:
            return Bomb()
        case .tint:
            return Tint()
        case .seed:
            return Seed()
        }
    }
    
    // TODO: - algum dia, quando alguem quiser e tiver vontade, precisamos mudar o local dessas funcoes para outro Manager :)
    func executeAction(value: GameEntity) {
        if let bomb = value as? Bomb {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.3))
                handleBomb(bomb: bomb)
                return
            }
        }
        
        if let tint = value as? Tint {
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(0.4))
                guard let self = self, let fx = self.fxManager else { return }
                if let node = tint.node {
                    fx.explodeTint(node: node, entity: tint)
                }
            }
        }
        
        if let seed = value as? Seed {
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(1))
                guard let self = self, let fx = self.fxManager else { return }
                if let node = seed.node {
                    fx.explodeSeed(node: node, entity: seed, gridManager: self.gridManager)
                }
            }
        }
    }
    
    private func handleBomb(bomb: Bomb) {
        bomb.startFuseAnimation()
        activeBombs.append(bomb)
        
        if activeBombs.count == 1 {
            audioBlowService.start { [weak self] level in
                guard let self = self else { return }
                if level > 0.5 {
                    Task { @MainActor in
                        self.defuseAllBombs()
                    }
                }
            }
        }
        
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            self?.triggerExplosionIfActive(bomb: bomb)
        }
    }
    
    private func defuseAllBombs() {
        guard !activeBombs.isEmpty else { return }
        
        for bomb in activeBombs {
            bomb.body?.applyForce(.init(dx: 0, dy: 40000))
            Task {
                try? await Task.sleep(for: .seconds(1))
                entityManager?.remove(entity: bomb)
            }
        }
        
        activeBombs.removeAll()
        audioBlowService.stop()
    }
    
    private func triggerExplosionIfActive(bomb: Bomb) {
        if let index = activeBombs.firstIndex(of: bomb) {
            activeBombs.remove(at: index)
            
            if let node = bomb.node {
                fxManager?.explode(node: node, entity: bomb)
            }
            
            if activeBombs.isEmpty {
                audioBlowService.stop()
            }
        }
    }
}
