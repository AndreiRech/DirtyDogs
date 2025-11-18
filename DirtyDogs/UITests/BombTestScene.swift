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
        let matchManager = MatchManager()          // ✅ MatchManager "fake" só pra cena
        super.init(matchManager: matchManager, size: screenSize)
        matchManager.delegate = self               // se quiser, mas aqui nem é obrigatório
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Opcional: muda fundo pra destacar a explosão
        backgroundColor = .black

        // Opcional: se não quiser a bola padrão que o PhysicsScene spawna:
        // remove todas as entidades/nodes que já estejam na cena
        children.forEach { node in
            if node.name == "ball" {
                node.removeFromParent()
            }
        }
    }

    // Função de teste: cria uma bomba e faz ela explodir
    func spawnAndExplodeTestBomb() {
        // 1) Cria a bomba no meio da tela
        let bomb = Bomb()
        let center = CGPoint(x: frame.midX, y: frame.midY)
        bomb.setPosition(to: center)
        entityManager?.add(entity: bomb)

        // 2) Anima o pavio
        bomb.startFuseAnimation()

        // 3) Explode depois de um pequeno delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let node = bomb.node {
                self.explode(node: node, entity: bomb)
            }
        }
    }
}
