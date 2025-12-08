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
    
    private var loopPlayersA: [String: AVAudioPlayer] = [:]
    private var loopPlayersB: [String: AVAudioPlayer] = [:]
    
    private var loopTimers: [String: Timer] = [:]
    private var simpleLoopPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {}
    
    func preload(sound: String) {
        _ = loadOneTimePlayer(for: sound)
        _ = loadLoopPlayerA(for: sound)
        _ = loadLoopPlayerB(for: sound)
    }
    
    func preload(sounds: [String]) {
        for sound in sounds {
            preload(sound: sound)
        }
    }
    
    func play(sound: String, volume: Float = 1.0) {
        guard let player = loadOneTimePlayer(for: sound) else { return }
        
        player.volume = volume
        player.currentTime = 0
        player.numberOfLoops = 0
        player.play()
    }
    
    func playLoop(sound: String, volume: Float = 1.0) {
        // Se já está tocando em loop, não tocar de novo
        if loopTimers[sound] != nil { return }
        
        guard
            let playerA = loadLoopPlayerA(for: sound),
            let playerB = loadLoopPlayerB(for: sound)
        else {
            print("❌ AudioService: loop players not loaded for \(sound)")
            return
        }
        
        playerA.volume = volume
        playerB.volume = volume
        playerA.currentTime = 0
        playerA.play()
        
        let duration = playerA.duration
        
        
        let interval = max(0.05, duration * 0.55)
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            
            if !playerA.isPlaying {
                playerA.currentTime = 0
                playerA.play()
            } else {
                playerB.currentTime = 0
                playerB.play()
            }
        }
        
        loopTimers[sound] = timer
    }
    
    func stop(sound: String) {
        loopTimers[sound]?.invalidate()
        loopTimers.removeValue(forKey: sound)
        // Para players
        loopPlayersA[sound]?.stop()
        loopPlayersB[sound]?.stop()
    }
    
    func stopAll() {
        loopTimers.values.forEach { $0.invalidate() }
        loopTimers.removeAll()
        
        loopPlayersA.values.forEach { $0.stop() }
        loopPlayersB.values.forEach { $0.stop() }
    }
    
    private func loadOneTimePlayer(for name: String) -> AVAudioPlayer? {
        
        if let existing = players[name] {
            return existing
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("❌ AudioService: sound not found -> \(name)")
            return nil
        }
        
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        
        if let p = player {
            players[name] = p
        }
        
        return player
    }
    
    private func loadLoopPlayerA(for name: String) -> AVAudioPlayer? {
        
        if let existing = loopPlayersA[name] {
            return existing
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("❌ AudioService: sound not found -> \(name)")
            return nil
        }
        
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        
        if let p = player {
            loopPlayersA[name] = p
        }
        
        return player
    }
    
    private func loadLoopPlayerB(for name: String) -> AVAudioPlayer? {
        
        if let existing = loopPlayersB[name] {
            return existing
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("❌ AudioService: sound not found -> \(name)")
            return nil
        }
        
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        
        if let p = player {
            loopPlayersB[name] = p
        }
        
        return player
    }

    func playLoopSimple(sound: String, volume: Float = 1.0) {
       
        if let existing = simpleLoopPlayers[sound], existing.isPlaying {
            existing.volume = volume
            return
        }

        guard let url = Bundle.main.url(forResource: sound, withExtension: nil) else {
            print("AudioService: sound not found -> \(sound)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = volume
            player.prepareToPlay()
            player.play()

            simpleLoopPlayers[sound] = player

        } catch {
            print("❌ Error loading loop audio:", error)
        }
    }
    
    func stopSimpleLoop(sound: String) {
        simpleLoopPlayers[sound]?.stop()
        simpleLoopPlayers.removeValue(forKey: sound)
    }


}
