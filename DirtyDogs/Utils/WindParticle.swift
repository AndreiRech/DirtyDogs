//
//  WindParticle.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import SwiftUI

struct WindParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var life: CGFloat

    var opacity: CGFloat {
        max(0, 1 - life)
    }

    init() {
        x = CGFloat.random(in: -90...90)
        y = CGFloat.random(in: -140...40)
        size = CGFloat.random(in: 6...12)
        life = 0
    }
}
