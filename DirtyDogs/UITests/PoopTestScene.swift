//
//  PoopTestScene.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 21/11/25.
//

import SpriteKit
import GameplayKit

class PoopTestScene: GameScene {

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

    /// Testa o cocô usando a nova arquitetura (executeAction cuida da explosão)
   func spawnAndExplodeTestPoop() {
       let center = CGPoint(x: frame.midX, y: frame.midY)
       if let spawn = spawnManager {
           let entity = Poop()
           entity.setPosition(to: center)
           entityManager.add(entity: entity)
           spawn.executeAction(value: entity)   //força a explosão
       }
   }


    func spawnPoopOnly() {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        spawnManager.spawnItem(at: center, entity: .poop)
    }

    func explodePoopAlone() {
        let fake = SKNode()
        fake.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(fake)
//        spawnManager.executeAction(value: fake)
    }
}

