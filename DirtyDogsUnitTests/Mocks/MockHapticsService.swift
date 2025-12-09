//
//  MockHapticsService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 26/11/25.
//

@testable import DirtyDogs
import UIKit

class MockHapticsService: HapticsServiceProtocol {
    var isHapticsEnabled: Bool = true
    var prepareHapticsCalled = false
    var lastHaptics: SoundEffect?
    
    func prepareHaptics() { prepareHapticsCalled = true }
    func complexSuccess() { lastHaptics = .success }
    func explosionBomb() { lastHaptics = .bombExploded }
    func findItem() { lastHaptics = .itemFound }
    func cleanScreen() { lastHaptics = .poopSplash }
    func feedbackGenerator(_ style: UIImpactFeedbackGenerator.FeedbackStyle) { lastHaptics = .gridTouch }
}
