//
//  DirtyDogsApp.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI

@main
struct DirtyDogsApp: App {
    @State var matchManager = MatchManager()
    
    var body: some Scene {
        WindowGroup {
//             ControllerView(matchManager: matchManager)
//            InventoryView(bonesFound: 1, availableItems: [])
//            ControllerView(matchManager: matchManager)
            GameView(viewModel:
                        GameViewModel(
                            matchManager: MatchManager(),
                            speechService: SpeechService()
                        ))
            //BombTestView()
            //PoopTestView()
        }
    }
}
