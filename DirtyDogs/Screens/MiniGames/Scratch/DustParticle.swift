//
//  DustParticle.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 09/12/25.
//

import SwiftUI

struct DustParticle: Identifiable, Equatable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    var velocity: CGVector
    var creationTime: Date
    var rotation: Double = 0.0
}
