//
//  PoopTestScene.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 21/11/25.
//

import SpriteKit
import GameplayKit

class PoopTestScene: PhysicsScene {

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

    /// Testa o cocô usando a nova arquitetura (executeAction cuida da explosão)
    func spawnAndExplodeTestPoop() {
        spawnItem(entity: .poop) // explode automaticamente via executeAction
    }

    func spawnPoopOnly() {
        spawnItem(entity: .poop)
    }

    func explodePoopAlone() {
        let fake = SKNode()
        fake.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(fake)
        explodePoop(node: fake, entity: nil)
    }
}

