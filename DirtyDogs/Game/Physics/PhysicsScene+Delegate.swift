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
        let type = data.objectType
        
        switch type {
        case .ball:
            self.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .ball)
        case .bomb:
            self.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .bomb)
        case .poop:
            self.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .poop)
        }
    }
}

