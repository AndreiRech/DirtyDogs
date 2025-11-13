//
//  PhysicsObjectData.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

struct PhysicsObjectData: Codable {
    let objectType: PhysicsObjectType
    let x: CGFloat
    let y: CGFloat
    let side: EdgeSide
}
