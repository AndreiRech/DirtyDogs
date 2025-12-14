//
//  GamePacketTests.swift
//  GamePacketTests
//
//  Created by Andrei Rech on 25/11/25.
//

import Testing
import Foundation
@testable import DirtyDogs

@MainActor
struct GamePacketTests {
    @Test("Encode - Test gamePacket encoding and decoding")
    func gamePacketEncoding() async throws {
        // Given
        let physicsData = PhysicsObjectData(objectType: .bomb, x: 100, y: 200, side: .top)
        let packet = GamePacket(type: .spawnPhysicsObject, physicsData: physicsData)
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(packet)
        
        let decoder = JSONDecoder()
        let decodedPacket = try decoder.decode(GamePacket.self, from: data)
        
        // Then
        #expect(decodedPacket.physicsData?.objectType == .bomb)
        #expect(decodedPacket.physicsData?.x == 100)
    }
}
