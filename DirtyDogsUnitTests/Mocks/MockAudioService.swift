//
//  MockAudioService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 09/12/25.
//

@testable import DirtyDogs

class MockAudioService: AudioServiceProtocol {
    var isSoundEnabled: Bool = true
    var preloadedSounds: [String] = []
    var playingSounds: [String: Float] = [:]
    var loopingSounds: [String] = []

    func preload(sound: String) {
        preloadedSounds.append(sound)
    }

    func preload(sounds: [String]) {
        preloadedSounds.append(contentsOf: sounds)
    }

    func play(sound: String, volume: Float) {
        playingSounds[sound] = volume
    }

    func playLoop(sound: String, volume: Float) {
        loopingSounds.append(sound)
        playingSounds[sound] = volume
    }

    func stop(sound: String) {
        playingSounds.removeValue(forKey: sound)
        loopingSounds.removeAll { $0 == sound }
    }

    func stopAll() {
        playingSounds.removeAll()
        loopingSounds.removeAll()
    }

    func playLoopSimple(sound: String, volume: Float) {
        playLoop(sound: sound, volume: volume)
    }

    func stopSimpleLoop(sound: String) {
        stop(sound: sound)
    }
}
