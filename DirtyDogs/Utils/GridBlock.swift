//
//  GridCell.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

struct GridBlock: Identifiable, Hashable {
    let id = UUID()
    var layer: Int = 0
    var cleared: Bool { layer >= 3 }
    var reward: Reward
    var rewardLayer: Int = 0
}

struct SheetIndex: Identifiable {
    var id: Int { value }
    let value: Int
}
