//
//  WindViewProtocol.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import SwiftUI

protocol WindMiniGameViewModelProtocol {
    var balloonOffset: CGFloat { get }
    var centerProgress: CGFloat { get }
    var particles: [WindParticle] { get }
    var layer: Int { get }
    
    var reward: Reward { get }
    var showResult: Bool { get set }
    var isAnimating: Bool { get set }
    var lightX: CGFloat { get set }
    var lightY: CGFloat { get set }

    func start()
    func cancel()
    func getRewardImage() -> String
    func startLightSweep(size: CGFloat)
}
