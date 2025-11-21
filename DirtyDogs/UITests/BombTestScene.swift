//
//  BombTestScene.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 18/11/25.
//

import SpriteKit
import GameplayKit


class BombTestScene: PhysicsScene {

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
        haptics.prepareHaptics()
    }

    /// Testa a bomba usando a nova arquitetura (executeAction cuida da explosão)
    func spawnAndExplodeTestBomb() {
        let point: CGPoint = .init(x: frame.midX, y: frame.maxY - 100)
        spawnItem(at: point, entity: .bomb) // explode automaticamente via executeAction
    }
}



