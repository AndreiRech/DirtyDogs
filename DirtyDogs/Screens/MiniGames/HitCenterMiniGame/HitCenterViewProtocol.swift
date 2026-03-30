//
//  HitCenterViewProtocol.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import SwiftUI

protocol HitCenterMiniGameViewModelProtocol: Observable {
    var layer: Int { get }
    var angle: Double { get }
    var hitTargets: [Bool] { get }
    var targetAngles: [Double] { get }
    
    var reward: Reward { get }
    var showResult: Bool { get set }
    var isAnimating: Bool { get set }
    var lightX: CGFloat { get set }
    var lightY: CGFloat { get set }

    func start()
    func tap()
    func getRewardImage() -> String
    func startLightSweep(size: CGFloat)
}
