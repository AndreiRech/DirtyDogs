//
//  GameOverViewModelProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

protocol GameOverViewModelProtocol {
    var gameResult: GameState { get }
    var screenTextLines: [String] { get }
    func returnToMenu()
}
