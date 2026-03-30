//
//  HitCenterViewModel.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import SwiftUI
import Combine

@MainActor
@Observable
class HitCenterMiniGameViewModel: HitCenterMiniGameViewModelProtocol {

    let layer: Int
    let reward: Reward
    private let onComplete: () -> Void
    private let playHaptics: () -> Void

    var angle: Double = 0
    var speed: Double = 2
    var hitTargets = [false, false, false]
    let targetAngles: [Double] = [0, 120, 240]

    private var timer: AnyCancellable?
    
    var showResult: Bool = false
    var isAnimating: Bool = false
    var lightX: CGFloat = 0
    var lightY: CGFloat = 0

    init(layer: Int,
         reward: Reward,
         onComplete: @escaping () -> Void,
         playHaptics: @escaping () -> Void)
    {
        self.layer = layer
        self.reward = reward
        self.onComplete = onComplete
        self.playHaptics = playHaptics
    }

    func start() {
        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
    }

    private func update() {
        if showResult { return }
        angle += speed
        angle.formTruncatingRemainder(dividingBy: 360)
    }

    func tap() {
        if showResult { return }
        let tolerance = 15.0
        let currentAngle = angle.truncatingRemainder(dividingBy: 360)

        for i in 0..<3 {
            let diff = abs(currentAngle - targetAngles[i])

            if diff < tolerance || abs(diff - 360) < tolerance {
                if !hitTargets[i] {
                    hitTargets[i] = true
                    speed += 1.2
                    AudioService.shared.play(sound: "ReceiveItem.wav", volume: 0.1)
                }
            }
        }

        if hitTargets.allSatisfy({ $0 }) && !showResult {
            triggerWin()
        }
    }
    
    private func triggerWin() {
        timer?.cancel()
        showResult = true
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
