//
//  GridViewModelProtocol.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

protocol GridViewModelProtocol {
    var columns: [GridItem] { get }
    var blocks: [GridBlock] { get set }
    var selectedIndex: Int? { get set }
    
    var matchManager: MatchManager { get set }
    var gameScene: GameScene { get set }
    
    func resetGrid()
    func spawnBall()
    
    func completeScratch(at index: Int)
    func cancelScratch()
}
