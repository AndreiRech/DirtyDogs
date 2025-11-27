//
//  GameViewModel.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation
import SpriteKit
import SwiftUI

@Observable
class GameViewModel: GameViewModelProtocol, GameSceneDelegate, InventoryDelegate {
    var gameScene: GameScene
    var matchManager: MatchManager
    var hapticsService: HapticsServiceProtocol
    var selectedIndex: Int? = nil
    var bonesFound: Int = 0
    var showQuitConfirmation: Bool = false
    var slotThatShouldAnimate: Int? = nil
    
    var availableItems: [InventoryItem?] = [
        nil,
        nil,
        nil
    ]
    
    // MARK: Init and StateControll functions
    init(matchManager: MatchManager, hapticsService: HapticsServiceProtocol) {
        self.matchManager = matchManager
        self.hapticsService = hapticsService
        
        let scene = GameScene(
            matchManager: matchManager,
            size: .zero,
            hapticService: hapticsService
        )
        scene.scaleMode = .resizeFill
        self.gameScene = scene
        
        self.matchManager.delegate = scene
        self.gameScene.uiDelegate = self
        self.gameScene.inventoryDelegate = self
    }
    
    func onAppear() {
    }
    
    func onDisappear() {
        if !matchManager.isGameOver {
            matchManager.endGame(with: .quit)
        }
    }
    
    func endGame(with event: PacketType) {
        matchManager.endGame(with: event)
    }
    
    // MARK: Game functions
    func resetGrid() {
        gameScene.resetGameGrid()
    }
    
    func spawnItem(type: PhysicsObjectType) {
        gameScene.spawnItem(type: type)
    }
    
    func playHaptics(sound: SoundEffect) {
        gameScene.playSoundEffect(sound: sound)
    }
    
    func completeScratch(at index: Int) {
        let entity = gameScene.revealItem(at: index)
        
        if let entity = entity {
            switch entity {
            case .bone:
                bonesFound += 1
                if bonesFound == 3 {
                    endGame(with: .victory)
                }
            case .bomb, .seed, .poop:
                guard let entityFound = entity.toPhysicsObject else { break }
                spawnItem(type: entityFound)
            default:
                break
            }
        }
        
        self.selectedIndex = nil
    }
    
    func cancelScratch() {
        self.selectedIndex = nil
    }
    
    func didTapBlock(_ index: Int) {
        let block = gameScene.gridManager.blocks[index]
        
        if block.cleared { return }
        
        Task { @MainActor in
            self.selectedIndex = index
        }
    }
    
    func didCollect(item: InventoryItem) {
        if let index = availableItems.firstIndex(where: { $0 == nil }){
            withAnimation {
                availableItems[index] = item
            }
        }
        
        inventoryDidUpdate()
    }
    
    func didUse(item: InventoryItem) {
        if let index = availableItems.firstIndex(of: item) {
            withAnimation {
                availableItems[index] = nil
                slotThatShouldAnimate = index
            }
        }
        
        let type: PhysicsObjectType
                
        switch item.imageName {
        case "Bomb-Button":
            type = .bomb
        case "Seed-Button":
            type = .seed
        case "Tint-Button":
            type = .poop
        default:
            type = .poop
        }
        spawnItem(type: type)
        inventoryDidUpdate()
        
        DispatchQueue.main.async {
                self.slotThatShouldAnimate = nil
            }
    }
    
    func isInventoryFull() -> Bool {
        availableItems.allSatisfy{ $0 != nil }
    }
    
    func inventoryDidUpdate(){
        gameScene.setupBorders()
    }
}
