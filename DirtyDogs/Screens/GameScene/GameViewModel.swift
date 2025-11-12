//
//  GameViewModel.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation
import SpriteKit

@Observable
class GameViewModel: GameViewModelProtocol {
    var physicsScene: PhysicsScene
    var matchManager: MatchManager
    private var speechService: SpeechServiceProtocol
    
    init(matchManager: MatchManager, speechService: SpeechServiceProtocol) {
        self.matchManager = matchManager
        self.speechService = speechService
        
        let scene = PhysicsScene(
            matchManager: matchManager,
            size: .zero
        )
        scene.scaleMode = .resizeFill
        self.physicsScene = scene
        
        self.matchManager.delegate = scene
    }
    
    func onAppear() {
        speechService.startListening(matchManager: matchManager)
    }
    
    func onDisappear() {
        speechService.stopListening()
    }
    
    func endGame() {
        matchManager.endGame()
    }
}
