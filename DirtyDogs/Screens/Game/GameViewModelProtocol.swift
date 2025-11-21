//
//  GameViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol GameViewModelProtocol {
    var physicsScene: GameScene { get }
    var matchManager: MatchManager { get }
    
    func onAppear()
    func onDisappear()
    func endGame(with event: PacketType)
}
