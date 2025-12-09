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
        
        let entity = spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: type)

        if let bomb = entity as? Bomb {
            bomb.setReceived(value: true)
            uiDelegate?.didReceiveBomb(bomb)
        }
        
//        switch type {
//        case .ball:
//            spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .ball)
//        case .bomb:
//            spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .bomb)
//        case .tint:
//            spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .tint)
//        case .seed:
//            spawnManager.spawnItem(at: spawnPoint, goingTo: arrivingSide, entity: .seed)
//        }
    }
}
