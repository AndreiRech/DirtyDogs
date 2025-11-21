//
//  GameScene.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 21/11/25.
//

import SpriteKit
import GameplayKit

public class GameScene: PhysicsScene {

    // MARK: - Grid Model
    var blocks: [GridBlock] = Array(repeating: GridBlock(), count: 9)
    var blockNodes: [SKSpriteNode] = []

    weak var uiDelegate: GameSceneDelegate?

    private let rows = 3
    private let cols = 3
    private let spacing: CGFloat = 12
    private let blockSize = CGSize(width: 110, height: 110)
    
    // Container para o grid
    private var gridContainer: SKNode!
    
    // MARK: - FIRST LOAD
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Criar container do grid
        gridContainer = SKNode()
        gridContainer.zPosition = 10
        addChild(gridContainer)
        
        rebuildGrid()
    }

    // MARK: - PUBLIC: Reconstruir grid
    public func rebuildGrid() {
        blockNodes.forEach { $0.removeFromParent() }
        blockNodes.removeAll()
        setupGrid()
    }

    // MARK: - Setup Grid
    private func setupGrid() {
        let totalWidth = CGFloat(cols) * blockSize.width + CGFloat(cols - 1) * spacing
        let totalHeight = CGFloat(rows) * blockSize.height + CGFloat(rows - 1) * spacing

        // Posicionar o grid mais para baixo na tela
        let startX = frame.midX - totalWidth / 2 + blockSize.width / 2
        let startY = frame.maxY - 200 - blockSize.height / 2  // 200pt do topo

        for row in 0..<rows {
            for col in 0..<cols {
                let index = row * cols + col
                let texture = textureForLayer(blocks[index].layer)
                let node = SKSpriteNode(texture: texture)

                node.size = blockSize
                node.position = CGPoint(
                    x: startX + CGFloat(col) * (blockSize.width + spacing),
                    y: startY - CGFloat(row) * (blockSize.height + spacing)
                )

                node.name = "block_\(index)"
                node.zPosition = -1  // Grid fica ATRÁS dos itens

                // Border
                let border = SKShapeNode(rectOf: blockSize, cornerRadius: 20)
                border.strokeColor = .white.withAlphaComponent(0.15)
                border.lineWidth = 2
                border.zPosition = 1
                node.addChild(border)

                gridContainer.addChild(node)
                blockNodes.append(node)
            }
        }
    }

    private func textureForLayer(_ layer: Int) -> SKTexture {
        switch layer {
        case 0: return SKTexture(imageNamed: "grass")
        case 1: return SKTexture(imageNamed: "earth")
        case 2: return SKTexture(imageNamed: "rocks")
        default: return SKTexture()
        }
    }

    // MARK: - TOUCHES
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Verificar se tocou em um bloco do grid
        let gridLocation = touch.location(in: gridContainer)
        if let tapped = gridContainer.nodes(at: gridLocation).first(where: { $0.name?.contains("block_") == true }) {
            handleBlockTap(tapped)
            return
        }

        // Se não tocou no grid, passa para o PhysicsScene (arrastar bola)
        super.touchesBegan(touches, with: event)
    }

    private func handleBlockTap(_ node: SKNode) {
        guard let name = node.name else { return }
        guard let index = Int(name.replacingOccurrences(of: "block_", with: "")) else { return }
        uiDelegate?.didTapBlock(index)
    }

    // MARK: - Atualização da camada (vir do ScratchView)
    public func updateBlockLayer(at index: Int, to newLayer: Int) {
        blocks[index].layer = newLayer
        blockNodes[index].texture = textureForLayer(newLayer)
    }

    public func markBlockCleared(at index: Int) {
        blocks[index].layer = 3

        let check = SKLabelNode(text: "✓")
        check.fontName = "Arial-BoldMT"
        check.fontSize = 38
        check.zPosition = 2
        check.position = .zero

        blockNodes[index].addChild(check)
    }
    
    // MARK: - Spawn Ball para enviar ao outro jogador
    public func spawnAndSendBall() {
        // Criar bolinha acima do grid
        let spawnPoint = CGPoint(x: frame.midX, y: frame.maxY - 100)
        spawnBall(at: spawnPoint, entity: .ball)
    }
}
