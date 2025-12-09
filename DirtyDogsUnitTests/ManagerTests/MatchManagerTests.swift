//
//  MatchManagerTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 26/11/25.
//

import Testing
import Foundation
@testable import DirtyDogs

@MainActor
struct MatchManagerTests {
    @Test("End Game - Verify state transition to Victory")
    func endGameVictory() {
        // Given
        let matchManager = MatchManager()
        matchManager.gameState = .inGame
        
        // When
        matchManager.endGame(with: .victory)
        
        // Then
        #expect(matchManager.gameState == .victory)
        #expect(matchManager.isGameOver == true)
    }
    
    @Test("Return to Menu - Verify state reset")
    func returnToMenuReset() {
        // Given
        let matchManager = MatchManager()
        matchManager.gameState = .defeat
        matchManager.isGameOver = true
        
        // When
        matchManager.returnToMenu()
        
        // Then
        #expect(matchManager.gameState == .none)
        #expect(matchManager.isGameOver == false)
    }
}
