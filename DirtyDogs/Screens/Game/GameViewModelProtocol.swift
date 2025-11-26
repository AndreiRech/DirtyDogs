//
//  GameViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

protocol GameViewModelProtocol {
    var gameScene: GameScene { get }
    var matchManager: MatchManager { get }
    var bonesFound: Int { get set }
    
    var selectedIndex: Int? { get set }
    var availableItems: [InventoryItem?] { get }
    
    func onAppear()
    func onDisappear()
    
    func endGame(with event: PacketType)
    func resetGrid()
    func spawnItem(type: PhysicsObjectType)
    
    func didUse(item: InventoryItem)
    func isInventoryFull() -> Bool
    
    func completeScratch(at index: Int)
    func cancelScratch()
}
