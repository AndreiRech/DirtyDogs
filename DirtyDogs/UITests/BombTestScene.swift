//
//  BombTestScene.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 18/11/25.
//

import SpriteKit
import GameplayKit

class BombTestScene: PhysicsScene {

    // Inicializador simples para testes
    init() {
        let screenSize = UIScreen.main.bounds.size
        let matchManager = MatchManager()     // MatchManager fake só pra cena de teste
        super.init(matchManager: matchManager, size: screenSize)
        matchManager.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        backgroundColor = .black

        // Remove a bola padrão que o PhysicsScene spawna
        children.forEach { node in
            if node.name == "ball" {
                node.removeFromParent()
            }
        }

        // Haptics (já existe no PhysicsScene, mas reforçamos para testes)
        haptics.prepareHaptics()
    }

    // MARK: - TESTE PRINCIPAL
    func spawnAndExplodeTestBomb() {
        let bomb = Bomb()
        let center = CGPoint(x: frame.midX, y: frame.midY)

        bomb.setPosition(to: center)
        entityManager?.add(entity: bomb)

        bomb.startFuseAnimation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if let node = bomb.node {
                self.explode(node: node, entity: bomb)
            }
        }
    }

    // MARK: - OPCIONAIS PARA TESTAR INDIVIDUALMENTE
    func spawnBombOnly() {
        let bomb = Bomb()
        bomb.setPosition(to: CGPoint(x: frame.midX, y: frame.midY))
        entityManager?.add(entity: bomb)
        bomb.startFuseAnimation()
    }

    func explodeWithoutSpawn() {
        let fakeNode = SKNode()
        fakeNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(fakeNode)
        explode(node: fakeNode, entity: nil)
    }

    func testShakeOnly() {
        shake(intensity: 20, duration: 0.45)
        haptics.explosionBomb()
    }
}

