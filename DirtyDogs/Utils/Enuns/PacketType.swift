//
//  PacketType.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 13/11/25.
//

import Foundation

enum PacketType: String, Codable {
    case began
    case victory
    case quit
    case spawnPhysicsObject
}
