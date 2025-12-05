//
//  SettingsService.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 04/12/25.
//

import SwiftUI


class SettingsService: SettingsServiceProtocol {
    
    private let soundKey = "soundEnabled"
    private let hapticsKey = "hapticsEnabled"
    
    init() {
        if UserDefaults.standard.object(forKey: soundKey) == nil {
            UserDefaults.standard.set(true, forKey: soundKey)
        }
        if UserDefaults.standard.object(forKey: hapticsKey) == nil {
            UserDefaults.standard.set(true, forKey: hapticsKey)
        }
    }
    
    var soundEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: soundKey) }
        set { UserDefaults.standard.set(newValue, forKey: soundKey) }
    }
    
    var hapticsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: hapticsKey) }
        set { UserDefaults.standard.set(newValue, forKey: hapticsKey) }
    }
}
