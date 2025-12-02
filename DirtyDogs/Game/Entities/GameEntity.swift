//
//  GameEntity.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 18/11/25.
//

import GameplayKit

protocol GameEntity: GKEntity {
    var body: SKPhysicsBody? { get }
    func setReceived(value: Bool)
    func getReceived() -> Bool
    func setPosition(to point: CGPoint)
}
