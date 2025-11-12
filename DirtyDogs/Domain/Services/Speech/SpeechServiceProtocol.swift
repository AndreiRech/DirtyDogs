//
//  SpeechServiceProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol SpeechServiceProtocol {
    func startListening(matchManager: MatchManager)
    func stopListening()
}
