//
//  PhysicsScene+Delegate.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

extension GameScene: MatchManagerDelegate {
    func spawnObject(with data: PhysicsObjectData) {
        let spawnPoint = CGPoint(x: data.x, y: data.y)
        let arrivingSide: EdgeSide = data.side
        let type = data.objectType
        
        switch type {
        case .ball:
            spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .ball)
        case .bomb:
            spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .bomb)
        case .poop:
            spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .poop)
        }
    }
}
