//
//  GameViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol GameViewModelProtocol {
    var gameScene: GameScene { get }
    var matchManager: MatchManager { get }
    
    var selectedIndex: Int? { get set }
    
    func onAppear()
    func onDisappear()
    
    func endGame(with event: PacketType)
    func resetGrid()
    func spawnItem(type: PhysicsObjectType)
    
    func completeScratch(at index: Int)
    func cancelScratch()
}
