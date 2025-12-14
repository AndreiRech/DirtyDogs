//
//  SettingsServiceProtocol.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 04/12/25.
//

import SwiftUI

protocol SettingsServiceProtocol {
    var soundEnabled: Bool { get set }
    var hapticsEnabled: Bool { get set }
    
    var onSoundChanged: ((Bool) -> Void)? { get set }
    var onHapticsChanged: ((Bool) -> Void)? { get set }
}
