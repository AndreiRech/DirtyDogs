//
//  HapticsService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import CoreHaptics
import UIKit

class HapticsService: HapticsServiceProtocol {
    private var engine: CHHapticEngine?
    
    var isHapticsEnabled: Bool = true
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func complexSuccess() {
        guard isHapticsEnabled else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1 + i)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func explosionBomb() {
        guard isHapticsEnabled else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events: [CHHapticEvent] = []

        events.append(
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 1.0),
                    .init(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            )
        )

        events.append(
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.8),
                    .init(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.03
            )
        )

        events.append(
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.6),
                    .init(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.06
            )
        )

        events.append(
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.9),
                    .init(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0.08,
                duration: 0.15
            )
        )

        events.append(
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.35),
                    .init(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.23,
                duration: 0.4
            )
        )

        events.append(
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.15),
                    .init(parameterID: .hapticSharpness, value: 0.1)
                ],
                relativeTime: 0.63,
                duration: 0.25
            )
        )

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play explosion haptic: \(error.localizedDescription)")
        }
    }

    func findItem() {
        guard isHapticsEnabled else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func cleanScreen() {
        guard isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func feedbackGenerator(_ style : UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

