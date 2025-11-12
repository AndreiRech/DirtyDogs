//
//  BallData.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

struct BallData: Codable {
    let x: CGFloat
    let y: CGFloat
    let side: EdgeSide
    var type: String = "ball"
}
