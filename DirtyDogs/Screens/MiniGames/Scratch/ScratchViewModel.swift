//
//  ScratchViewModel.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

@Observable
class ScratchViewModel: ScratchViewModelProtocol {
    let layer: Int
    let isClear: Bool
    let onComplete: () -> Void
    let playHaptics: () -> Void
    
    let reward: Reward
    var showResult: Bool = false
    var isAnimating: Bool = false
    
    var clearedCells: Set<Int> = []
    var gridPoints: [CGPoint] = []
    var cols: Int = 60
    var rows: Int = 0
    var revealRatio: CGFloat = 0
    let brushRadius: CGFloat = 20
    let targetRevealRatio: CGFloat = 0.7
    var wasCleared: Bool = false
    
    var lightX: CGFloat = 0
    var lightY: CGFloat = 0
    
    // Partículas
    var particles: [DustParticle] = []
    let particleDuration: Double = 0.6
    let particleEjectionSpeed: CGFloat = 3.0
    let maxParticlesPerUpdate = 5
    
    var scratchColor: Color {
        switch layer {
        case 0:
            return isClear ? Color.softGreen : Color.hardGreen
        case 1:
            return isClear ? Color.softBrown : Color.hardBrown
        case 2:
            return isClear ? Color.softGray : Color.hardGray
        default:
            return isClear ? Color.obsidianLight : Color.obsidianDark
        }
    }
    
    init(layer: Int, isClear: Bool, reward: Reward, onComplete: @escaping () -> Void, playHaptics: @escaping () -> Void, clearedCells: Set<Int> = [], gridPoints: [CGPoint] = [], cols: Int = 26, rows: Int = 0, revealRatio: CGFloat = 0) {
        self.layer = layer
        self.isClear = isClear
        self.reward = reward
        self.onComplete = onComplete
        self.clearedCells = clearedCells
        self.gridPoints = gridPoints
        self.cols = cols
        self.rows = rows
        self.revealRatio = revealRatio
        self.playHaptics = playHaptics
    }
    
    func getImage(nextLayer: Bool = false) -> String {
        var actualLayer = layer
        if nextLayer { actualLayer += 1 }
        
        switch actualLayer {
        case 0:
            return isClear ? "Grass-Light" : "Grass-Dark"
        case 1:
            return isClear ? "Dirt-Light" : "Dirt-Dark"
        case 2:
            return isClear ? "Stone-Light" : "Stone-Dark"
        default:
            return isClear ? "Obsidiam-Light" : "Obsidiam-Dark"
        }
    }
    
    func getRewardImage() -> String {
        switch reward {
        case .bomb:
            return "Bomb-Button"
        case .tint:
            return "Tint-Button"
        case .seed:
            return "Seed-Button"
        case .bone:
            return "Bone"
        default:
            return ""
        }
    }
    
    func setupGrid(in size: CGSize) {
        let inset: CGFloat = 4
        let w = size.width - inset * 2
        let h = size.height - inset * 2
        
        let stepX = w / CGFloat(cols)
        let stepY = stepX
        rows = Int(h / stepY)
        
        gridPoints = (0..<rows).flatMap { r in
            (0..<cols).map { c in
                CGPoint(x: inset + stepX * (CGFloat(c) + 0.5),
                        y: inset + stepY * (CGFloat(r) + 0.5))
            }
        }
    }
    
    func updateRevealRatio() {
        revealRatio = CGFloat(clearedCells.count) / CGFloat(gridPoints.count)
    }
    
    func startLightSweep(size: CGFloat) {
        lightX = -size
        lightY = -size
        
        withAnimation(
            .snappy(duration: 0.7)
                .repeatForever(autoreverses: true)
        ) {
            lightX = size
            lightY = size
        }
    }
    
    func createParticles(at point: CGPoint) {
        for _ in 0..<maxParticlesPerUpdate {
            let angle = CGFloat.random(in: 0..<(2 * .pi))
            let speed = CGFloat.random(in: 2.0...5.0)
            let velocity = CGVector(
                dx: speed * cos(angle),
                dy: speed * sin(angle)
            )

            let particle = DustParticle(
                position: point,
                color: scratchColor.opacity(Double.random(in: 0.7...1.0)),
                velocity: velocity,
                creationTime: Date(),
                rotation: Double.random(in: 0...360)
            )
            
            if particles.count < 300 {
                particles.append(particle)
            }
        }
    }

    func updateParticles() {
        let now = Date()
        var newParticles: [DustParticle] = []
        
        for particle in particles {
            var particle = particle
            let lifeTime = now.timeIntervalSince(particle.creationTime)
            
            if lifeTime > particleDuration {
                continue
            }
            
            // Adiciona gravidade
            particle.velocity.dy += 0.2
            
            particle.position.x += particle.velocity.dx
            particle.position.y += particle.velocity.dy
            
            // Rotação durante o movimento
            particle.rotation += Double.random(in: -5...5)
            
            let progress = lifeTime / particleDuration
            particle.opacity = max(0, 1.0 - progress * 1.2)
            particle.scale = 1.0 - progress * 0.3 // Diminui ao invés de aumentar
            
            newParticles.append(particle)
        }
        
        particles = newParticles
    }
}
