//
//  AudioProtocol.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 02/12/25.
//

import Foundation
import AVFoundation

protocol AudioServiceProtocol {
    var isSoundEnabled: Bool { get set }
    
    func preload(sound: String)
    func preload(sounds: [String])
    
    func play(sound: String, volume: Float)
    func playLoop(sound: String, volume: Float)
    
    func stop(sound: String)
    func stopAll()
    
    func playLoopSimple(sound: String, volume: Float)
    func stopSimpleLoop(sound: String)
}
