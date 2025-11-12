//
//  PhysicsScene+Delegate.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

extension PhysicsScene: MatchManagerDelegate {
    func spawnBall(at point: CGPoint, from side: EdgeSide) {
        self.spawnBall(at: point, goingTo: side)
    }
}
