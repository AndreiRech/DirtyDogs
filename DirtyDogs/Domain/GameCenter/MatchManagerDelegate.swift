//
//  MatchManagerDelegate.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

protocol MatchManagerDelegate: AnyObject {
    func spawnObject(with data: PhysicsObjectData)
}
