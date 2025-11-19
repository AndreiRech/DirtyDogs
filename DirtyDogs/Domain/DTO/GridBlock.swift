//
//  GridCell.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

struct GridBlock: Identifiable, Hashable {
    let id = UUID()
    var layer: Int = 0 // 0=grama, 1=terra, 2=pedra, 3=limpo
    var cleared: Bool { layer >= 3 }
}

struct SheetIndex: Identifiable {
    var id: Int { value }
    let value: Int
}
