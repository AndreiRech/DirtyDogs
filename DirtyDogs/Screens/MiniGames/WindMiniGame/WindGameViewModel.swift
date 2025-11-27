//
//  WindViewModel.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import SwiftUI
import Combine

@MainActor
@Observable
class WindMiniGameViewModel: WindMiniGameViewModelProtocol {

    let layer: Int
    private let audioService: AudioBlowServiceProtocol
    private let onComplete: () -> Void
    private let onCancel: () -> Void

    private var timer: AnyCancellable?
    private var particleTimer: AnyCancellable?

    private let gravity: CGFloat = 2.5
    private let windMultiplier: CGFloat = 28
    private let tolerance: CGFloat = 65

    var balloonOffset: CGFloat = 180
    var centerProgress: CGFloat = 0
    let requiredTime: CGFloat = 1.2

    var particles: [WindParticle] = []

    init(layer: Int,
         audioService: AudioBlowServiceProtocol,
         onComplete: @escaping () -> Void,
         onCancel: @escaping () -> Void)
    {
        self.layer = layer
        self.audioService = audioService
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    func start() {
        audioService.start { [weak self] level in
            self?.handleAudio(level)
        }

        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePhysics()
            }

        particleTimer = Timer.publish(every: 0.06, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnParticles()
            }
    }

    func cancel() {
        audioService.stop()
        timer?.cancel()
        particleTimer?.cancel()
    }

    // MARK: - Logica de vento
    private var windLevel: CGFloat = 0

    private func handleAudio(_ level: CGFloat) {
        windLevel = level
    }

    private func updatePhysics() {
        balloonOffset += gravity

        if windLevel > 0 {
            balloonOffset -= windLevel * windMultiplier
        }

        balloonOffset = min(balloonOffset, 200)
        balloonOffset = max(balloonOffset, -200)

        let inCenter = abs(balloonOffset) < tolerance

        if inCenter {
            centerProgress += 0.016
        } else {
            centerProgress = 0
        }

        if centerProgress >= requiredTime {
            onComplete()
        }

        // "envelhece" partículas
        for i in particles.indices {
            particles[i].life += 0.03
        }
        particles.removeAll { $0.life >= 1 }
    }

    private func spawnParticles() {
        guard windLevel > 0 else { return }
        let count = Int(windLevel * 15)

        for _ in 0..<count {
            particles.append(WindParticle())
        }
    }
}
