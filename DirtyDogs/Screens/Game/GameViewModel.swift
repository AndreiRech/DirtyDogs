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
    var bonesFound: Int = 0
    
    private var speechService: SpeechServiceProtocol
    
    // MARK: Init and StateControll functions
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
        
    // MARK: Game functions
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
        let entity = gameScene.gridManager.completeScratch(at: index)
        
        if let entity = entity {
            switch entity {
            case .bone:
                bonesFound += 1
                gameScene.fxManager.playComplex()
            case .bomb, .seed, .poop:
                guard let entityFound = entity.toPhysicsObject else { break }
                
                print("entidade encontrada: \(entityFound)")
                spawnItem(type: entityFound)
                gameScene.fxManager.playItemFind()
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
        Task { @MainActor in
            self.selectedIndex = index
        }
    }
}
