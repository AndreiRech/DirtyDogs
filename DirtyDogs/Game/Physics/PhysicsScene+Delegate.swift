//
//  PhysicsScene+Delegate.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

extension PhysicsScene: MatchManagerDelegate {
    func spawnObject(with data: PhysicsObjectData) {
        let spawnPoint = CGPoint(x: data.x, y: data.y)
        let arrivingSide: EdgeSide = data.side
//        let arrivingSide: EdgeSide = data.side == .top ? .top : (data.side == .left ? .right : .left)
        
        switch data.objectType {
        case .ball:
            self.spawnBall(at: spawnPoint, goingTo: arrivingSide, entity: .ball)
        }
    }
}
