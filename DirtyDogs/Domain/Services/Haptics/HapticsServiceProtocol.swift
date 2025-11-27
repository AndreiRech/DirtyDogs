//
//  HapticsServiceProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import UIKit

protocol HapticsServiceProtocol {
    func prepareHaptics()
    func complexSuccess()
    func explosionBomb()
    func findItem()
    func cleanScreen()
    func feedbackGenerator(_ style : UIImpactFeedbackGenerator.FeedbackStyle)
}
