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
class GameViewModel: GameViewModelProtocol, GameSceneDelegate {
    var gameScene: GameScene
    var matchManager: MatchManager
    var selectedIndex: Int? = nil
    
    private var speechService: SpeechServiceProtocol
    
    init(matchManager: MatchManager, speechService: SpeechServiceProtocol) {
        self.matchManager = matchManager
        self.speechService = speechService
        
        let scene = GameScene(
            matchManager: matchManager,
            size: .zero
        )
        scene.scaleMode = .resizeFill
        self.gameScene = scene
        
        self.matchManager.delegate = scene
        self.gameScene.uiDelegate = self
    }
    
    func onAppear() {
        // speechService.startListening(matchManager: matchManager)
    }
    
    func onDisappear() {
        matchManager.endGame(with: .quit)
        // speechService.stopListening()
    }
    
    func endGame(with event: PacketType) {
        matchManager.endGame(with: event)
    }
        
    func resetGrid() {
        gameScene.gridManager.resetGrid()
    }
    
    func spawnItem(type: PhysicsObjectType) {
        let spawnPoint = CGPoint(
            x: gameScene.frame.midX,
            y: gameScene.frame.maxY - 100
        )
        gameScene.spawnManager.spawnItem(at: spawnPoint, entity: type)
    }
    
    func completeScratch(at index: Int) {
        let currentLayer = gameScene.gridManager.blocks[index].layer
        gameScene.gridManager.updateBlockLayer(at: index, to: currentLayer + 1)
        self.selectedIndex = nil
    }
    
    func cancelScratch() {
        self.selectedIndex = nil
    }

    func didTapBlock(_ index: Int) {
        Task { @MainActor in
            self.selectedIndex = index
        }
    }
}
