//
//  Reward.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 24/11/25.
//

enum Reward: String, Codable {
    case none
    case bone
    case bomb
    case seed
    case tint
    
    var toPhysicsObject: PhysicsObjectType? {
        switch self {
        case .bomb: return .bomb
        case .tint: return .tint
        case .seed: return .seed
        default: return nil
        }
    }
}
