//
//  AudioService.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 02/12/25.
//

import Foundation
import AVFoundation

class AudioService: AudioServiceProtocol {
    
    static let shared = AudioService()
    
    private var players: [String: AVAudioPlayer] = [:]
    private let queue = DispatchQueue(label: "AudioServiceQueue")
    
    private init() {}
    
   
    
    func preload(sound: String) {
        _ = loadPlayer(for: sound)
    }
    
    func preload(sounds: [String]) {
        for s in sounds { preload(sound: s) }
    }
    
   
    
    func play(sound: String, volume: Float = 1.0) {
        queue.async {
            guard let player = self.loadPlayer(for: sound) else { return }
            player.volume = volume
            player.currentTime = 0
            player.numberOfLoops = 0
            player.play()
        }
    }
        
    func playLoop(sound: String, volume: Float = 1.0) {
        queue.async {
            guard let player = self.loadPlayer(for: sound) else { return }
            player.volume = volume
            player.numberOfLoops = -1
            player.currentTime = 0
            player.play()
        }
    }
    
    
    func stop(sound: String) {
        queue.async {
            guard let player = self.players[sound] else { return }
            player.stop()
        }
    }
    
    func stopAll() {
        queue.async {
            for (_, player) in self.players {
                player.stop()
            }
        }
    }
    
    // MARK: - Internal loader
    private func loadPlayer(for name: String) -> AVAudioPlayer? {
        
        if let existing = players[name] {
            return existing
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("❌ AudioService: sound not found -> \(name)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[name] = player
            return player
            
        } catch {
            print("❌ AudioService: failed to load \(name): \(error)")
            return nil
        }
    }
}
