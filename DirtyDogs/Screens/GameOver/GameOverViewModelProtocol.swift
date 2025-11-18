//
//  GameOverViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol GameOverViewModelProtocol {
    var gameResult: GameState { get }
    func returnToMenu()
    func getScreenText() -> String
}
