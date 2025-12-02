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
    private let onComplete: () -> Void

    var angle: Double = 0
    var speed: Double = 2
    var hitTargets = [false, false, false]
    let targetAngles: [Double] = [0, 120, 240]

    private var timer: AnyCancellable?

    init(layer: Int,
         onComplete: @escaping () -> Void)
    {
        self.layer = layer
        self.onComplete = onComplete
    }

    func start() {
        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
    }

    private func update() {
        angle += speed
        angle.formTruncatingRemainder(dividingBy: 360)
    }

    func tap() {
        let tolerance = 15.0
        let currentAngle = angle.truncatingRemainder(dividingBy: 360)

        for i in 0..<3 {
            let diff = abs(currentAngle - targetAngles[i])

            if diff < tolerance || abs(diff - 360) < tolerance {
                if !hitTargets[i] {
                    hitTargets[i] = true
                    speed += 1.2
                }
            }
        }

        if hitTargets.allSatisfy({ $0 }) {
            timer?.cancel()
            onComplete()
        }
    }
}
