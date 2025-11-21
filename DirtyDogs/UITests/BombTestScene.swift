//
//  BombTestScene.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 18/11/25.
//

import SpriteKit
import GameplayKit


class BombTestScene: GameScene {

    init() {
        let screenSize = UIScreen.main.bounds.size
        let matchManager = MatchManager()
        super.init(matchManager: matchManager, size: screenSize)
        matchManager.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .black
    }

    /// Testa a bomba usando a nova arquitetura (executeAction cuida da explosão)
    func spawnAndExplodeTestBomb() {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        spawnManager.spawnItem(at: center, entity: .bomb) // explode automaticamente via executeAction
    }
}



