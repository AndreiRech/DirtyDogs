//
//  MenuViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol MenuViewModelProtocol {
    var authenticatingState: PlayerAuthStateEnum { get }
    var isPlayButtonDisabled: Bool { get }
    
    func prepareHaptics()
    func playButtonTapped()
}
