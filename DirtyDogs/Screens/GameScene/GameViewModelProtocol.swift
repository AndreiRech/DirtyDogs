//
//  GameViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol GameViewModelProtocol: InventoryDelegate {
    var physicsScene: PhysicsScene { get }
    var matchManager: MatchManager { get }
    var availableItems: [InventoryItem] { get }
    
    func onAppear()
    func onDisappear()
    func endGame()
}
