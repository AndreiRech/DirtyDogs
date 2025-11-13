//
//  GamePacket.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 13/11/25.
//

import Foundation

struct GamePacket: Codable {
    let type: PacketType
    var uuid: String? = nil
    var physicsData: PhysicsObjectData? = nil

    init(type: PacketType) {
        self.type = type
    }

    init(type: PacketType, uuid: String) {
        self.type = type
        self.uuid = uuid
    }

    init(type: PacketType, physicsData: PhysicsObjectData) {
        self.type = type
        self.physicsData = physicsData
    }
}
