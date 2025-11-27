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

    func start()
    func cancel()
}
