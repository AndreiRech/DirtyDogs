//
//  ScratchViewModelTests.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 27/11/25.
//

import Testing
import SwiftUI
@testable import DirtyDogs

@MainActor
struct ScratchViewModelTests {
    @Test("Asset Logic - Verify correct image names for layers and states")
    func assetLogicLayers() {
        // Given
        let vmLayer0 = ScratchViewModel(layer: 0, isClear: true, reward: .none, onComplete: {}, playHaptics: {})
        
        // When & Then
        #expect(vmLayer0.getImage(nextLayer: false) == "Grass-Light")
        // When & Then
        #expect(vmLayer0.getImage(nextLayer: true) == "Dirt-Light")
        
        // Given
        let vmLayer1 = ScratchViewModel(layer: 1, isClear: false, reward: .none, onComplete: {}, playHaptics: {})
        
        // When & Then
        #expect(vmLayer1.getImage(nextLayer: false) == "Dirt-Dark")
        
        // Given
        let vmLayer2 = ScratchViewModel(layer: 2, isClear: true, reward: .none, onComplete: {}, playHaptics: {})
        
        // When & Then
        #expect(vmLayer2.getImage(nextLayer: false) == "Stone-Light")
    }
    
    @Test("Reward Assets - Verify correct image names for reward types")
    func rewardImageLogic() {
        // Given
        let vmBomb = ScratchViewModel(layer: 0, isClear: true, reward: .bomb, onComplete: {}, playHaptics: {})
        let vmPoop = ScratchViewModel(layer: 0, isClear: true, reward: .tint, onComplete: {}, playHaptics: {})
        let vmSeed = ScratchViewModel(layer: 0, isClear: true, reward: .seed, onComplete: {}, playHaptics: {})
        let vmBone = ScratchViewModel(layer: 0, isClear: true, reward: .bone, onComplete: {}, playHaptics: {})
        let vmNone = ScratchViewModel(layer: 0, isClear: true, reward: .none, onComplete: {}, playHaptics: {})
        
        // Then
        #expect(vmBomb.getRewardImage() == "Bomb-Button")
        #expect(vmPoop.getRewardImage() == "Tint-Button")
        #expect(vmSeed.getRewardImage() == "Seed-Button")
        #expect(vmBone.getRewardImage() == "Bone")
        #expect(vmNone.getRewardImage() == "")
    }
    
    @Test("Grid Setup - Verify points generation based on size")
    func setupGridCalculation() {
        // Given
        let viewModel = ScratchViewModel(layer: 0, isClear: true, reward: .none, onComplete: {}, playHaptics: {})
        let size = CGSize(width: 100, height: 100)
        
        // When
        viewModel.setupGrid(in: size)
        
        // Then
        #expect(!viewModel.gridPoints.isEmpty)
        #expect(viewModel.rows > 0)
        #expect(viewModel.gridPoints.count == viewModel.cols * viewModel.rows)
    }
    
    @Test("Reveal Ratio - Verify calculation progress")
    func revealRatioCalculation() {
        // Given
        let viewModel = ScratchViewModel(layer: 0, isClear: true, reward: .none, onComplete: {}, playHaptics: {})
        viewModel.gridPoints = [
            CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0),
            CGPoint(x: 0, y: 10), CGPoint(x: 10, y: 10)
        ]
        
        // When
        viewModel.clearedCells = [0]
        viewModel.updateRevealRatio()
        #expect(viewModel.revealRatio == 0.25)
        
        viewModel.clearedCells = [0, 1, 2]
        viewModel.updateRevealRatio()
        #expect(viewModel.revealRatio == 0.75)
        
        // Then
        #expect(viewModel.revealRatio >= viewModel.targetRevealRatio)
    }
}
