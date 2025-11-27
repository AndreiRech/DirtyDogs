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

    func start()
    func tap()
}
