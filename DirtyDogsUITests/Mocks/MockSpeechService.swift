//
//  MockSpeechService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 25/11/25.
//

@testable import DirtyDogs

struct MockSpeechService: SpeechServiceProtocol {
    func startListening(matchManager: MatchManager) {}
    func stopListening() {}
}
