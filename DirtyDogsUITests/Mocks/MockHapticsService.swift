//
//  MockHapticsService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 26/11/25.
//

@testable import DirtyDogs
import UIKit

class MockHapticsService: HapticsServiceProtocol {
    var complexSuccessCalled = false
    var prepareHapticsCalled = false
    
    func prepareHaptics() { prepareHapticsCalled = true }
    func complexSuccess() { complexSuccessCalled = true }
    func explosionBomb() {}
    func findItem() {}
    func cleanScreen() {}
    func feedbackGenerator(_ style: UIImpactFeedbackGenerator.FeedbackStyle) { }
}
