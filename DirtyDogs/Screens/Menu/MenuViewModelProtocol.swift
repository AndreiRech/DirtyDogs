//
//  MenuViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol MenuViewModelProtocol {
    var authenticatingState: PlayerAuthStateEnum { get }
    var isPlayButtonDisabled: Bool { get }
    var soundEnabled: Bool { get set }
    var hapticsEnabled: Bool { get set }
    var showTutorial: Bool { get set }
    
    func playButtonTapped()
    func toggleSound()
    func toggleHaptics()
}
