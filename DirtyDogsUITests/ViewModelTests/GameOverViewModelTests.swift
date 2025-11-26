//
//  GameOverViewModelTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 25/11/25.
//

import Testing
@testable import DirtyDogs

struct GameOverViewModelTests {
    @Test("Screen text matches game state", arguments: [
        (GameState.victory, ["You", "Won!"]),
        (GameState.defeat, ["You", "Lost!"]),
        (GameState.quit, ["Your", "Enemy", "Left"])
    ])
    func screenTextCheck(state: GameState, expectedLines: [String]) {
        // Given
        let matchManager = MatchManager()
        let viewModel = GameOverViewModel(matchManager: matchManager)
        
        // When
        matchManager.gameState = state
        
        // Then
        #expect(viewModel.screenTextLines == expectedLines)
    }
    
    @Test("Return to Menu - Resets MatchManager")
    func returnToMenuAction() {
        // Given
        let matchManager = MatchManager()
        matchManager.isGameOver = true
        matchManager.gameState = .victory
        let viewModel = GameOverViewModel(matchManager: matchManager)
        
        // When
        viewModel.returnToMenu()
        
        // Then
        #expect(matchManager.isGameOver == false)
        #expect(matchManager.gameState == .none)
    }
}
