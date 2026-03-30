//
//  WindMiniGameViewModel.swift
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
    let reward: Reward
    private let audioService: AudioBlowServiceProtocol
    private let onComplete: () -> Void
    private let onCancel: () -> Void
    private let playHaptics: () -> Void

    private var timer: AnyCancellable?
    private var particleTimer: AnyCancellable?

    private let gravity: CGFloat = 2.5
    private let windMultiplier: CGFloat = 18 // Reduzido para exigir um sopro mais forte
    private let tolerance: CGFloat = 65

    var balloonOffset: CGFloat = 180
    var centerProgress: CGFloat = 0
    let requiredTime: CGFloat = 1.2

    var particles: [WindParticle] = []
    
    var showResult: Bool = false
    var isAnimating: Bool = false
    var lightX: CGFloat = 0
    var lightY: CGFloat = 0

    init(layer: Int,
         audioService: AudioBlowServiceProtocol,
         reward: Reward,
         onComplete: @escaping () -> Void,
         onCancel: @escaping () -> Void,
         playHaptics: @escaping () -> Void)
    {
        self.layer = layer
        self.audioService = audioService
        self.reward = reward
        self.onComplete = onComplete
        self.onCancel = onCancel
        self.playHaptics = playHaptics
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

    private var windLevel: CGFloat = 0

    private func handleAudio(_ level: CGFloat) {
        if level > 0.15 {
            windLevel = level
        } else {
            windLevel = 0
        }
    }

    private func updatePhysics() {
        if showResult { return }
        
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

        if centerProgress >= requiredTime && !showResult {
            triggerWin()
        }

        for i in particles.indices {
            particles[i].life += 0.03
        }
        particles.removeAll { $0.life >= 1 }
    }

    private func spawnParticles() {
        guard windLevel > 0, !showResult else { return }
        let count = Int(windLevel * 15)

        for _ in 0..<count {
            particles.append(WindParticle())
        }
    }
    
    private func triggerWin() {
        showResult = true
        cancel()
        playHaptics()
        
        if getRewardImage() != "" {
            AudioService.shared.play(sound: "ReceiveItem.wav", volume: 0.2)
        }
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            onComplete()
        }
    }
    
    func getRewardImage() -> String {
        switch reward {
        case .bomb: return "Bomb-Button"
        case .tint: return "Tint-Button"
        case .seed: return "Seed-Button"
        case .bone: return "Bone"
        default: return ""
        }
    }
    
    func startLightSweep(size: CGFloat) {
        lightX = -size
        lightY = -size
        withAnimation(.snappy(duration: 0.7).repeatForever(autoreverses: true)) {
            lightX = size
            lightY = size
        }
    }
}
