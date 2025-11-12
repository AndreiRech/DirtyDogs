//
//  PhysicsCategory.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

struct PhysicsCategory {
    static let edge: UInt32 = 1 << 0
    static let parcel: UInt32 = 1 << 1
    static let sensorRight: UInt32 = 1 << 2
    static let sensorLeft: UInt32 = 1 << 3
    static let obstacle: UInt32 = 1 << 4
}
