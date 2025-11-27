//
//  MockHapticsService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 26/11/25.
//

@testable import DirtyDogs

class MockHapticsService: HapticsServiceProtocol {
    var complexSuccessCalled = false
    var prepareHapticsCalled = false
    
    func prepareHaptics() { prepareHapticsCalled = true }
    func complexSuccess() { complexSuccessCalled = true }
    func explosionBomb() {}
    func findItem() {}
    func cleanScreen() {}
}
