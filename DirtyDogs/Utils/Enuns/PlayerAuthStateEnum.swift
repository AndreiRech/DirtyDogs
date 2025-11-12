//
//  PlayerAuthStateEnum.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

enum PlayerAuthStateEnum: String {
    case authenticating = "Logging in into Game Center..."
    case notAuthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    
    case error = "There was an error. Please try again."
    case restricted = "You're not allowed to play. Please try again."
}
