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
//            InventoryView()
            ControllerView(matchManager: matchManager)
            //BombTestView()
            //PoopTestView()
        }
    }
}
