//
//  GridManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 23/11/25.
//

import SpriteKit
import GameplayKit

class GridManager {
    weak var scene: SKScene?
    weak var uiDelegate: GameSceneDelegate?
    
    var blocks: [GridBlock]
    var blockNodes: [SKSpriteNode] = []
    var gridContainer: SKNode
    
    private let rows = 4
    private let cols = 3
    private let spacing: CGFloat = -4
    private var blockSize: CGSize = .zero
    
    init(scene: SKScene) {
        self.scene = scene
        self.gridContainer = SKNode()
        self.blocks = Array(repeating: GridBlock(), count: rows * cols)
        self.gridContainer.zPosition = 10
        scene.addChild(gridContainer)
    }
    
    func setupGrid() {
        guard let scene = scene else { return }
        
        // Screen Size Grid
        let availableWidth = scene.frame.width - (CGFloat(cols - 1) * spacing) - 16
        let availableHeight = scene.frame.height - 400 - (CGFloat(rows - 1) * spacing)

        let blockWidth = availableWidth / CGFloat(cols)
        let blockHeight = availableHeight / CGFloat(rows)

        blockSize = CGSize(width: blockWidth, height: blockHeight)
        
        // Limpa tudo primeiro
        blockNodes.forEach { $0.removeFromParent() }
        blockNodes.removeAll()
        gridContainer.removeAllChildren()
        
        // Background
        let background = SKSpriteNode(imageNamed: "background2")
        background.size = CGSize(
            width: CGFloat(cols) * blockSize.width + CGFloat(cols - 1) * spacing + 20,
            height: CGFloat(rows) * blockSize.height + CGFloat(rows - 1) * spacing + 20
        )
        background.position = CGPoint(x: scene.frame.midX, y: scene.frame.maxY - 190 - background.size.height / 2)
        background.zPosition = -1
        gridContainer.addChild(background)
        
        // Grid - blocos por cima do background
        let totalWidth = CGFloat(cols) * blockSize.width + CGFloat(cols - 1) * spacing
        let startX = scene.frame.midX - totalWidth / 2 + blockSize.width / 2
        let startY = scene.frame.maxY - 200 - blockSize.height / 2
        
        for row in 0..<rows {
            for col in 0..<cols {
                let index = row * cols + col
                let texture = textureForLayer(layer: blocks[index].layer, index: index)
                let node = SKSpriteNode(texture: texture)
                
                node.size = blockSize
                node.position = CGPoint(
                    x: startX + CGFloat(col) * (blockSize.width + spacing),
                    y: startY - CGFloat(row) * (blockSize.height + spacing)
                )
                
                node.name = "block_\(index)"
                node.zPosition = 1
                
                
                if blocks[index].cleared {
                    addCheckmark(to: node)
                }
                
                gridContainer.addChild(node)
                blockNodes.append(node)
            }
        }
    }
    
    private func textureForLayer(layer: Int, index: Int) -> SKTexture {
        let isEven = index % 2 == 0
        switch layer {
        case 0:
            return SKTexture(imageNamed: isEven ? "grama1" : "grama2")
        case 1:
            return SKTexture(imageNamed: isEven ? "terra1" : "terra2")
        case 2:
            return SKTexture(imageNamed: isEven ? "pedra1" : "pedra2")
        default:
            return SKTexture()
        }
    }
    
    func handleTouch(_ touch: UITouch) -> Bool {
        guard let scene = scene else { return false }
        let locationInScene = touch.location(in: scene)
        let locationInGrid = scene.convert(locationInScene, to: gridContainer)
        
        if let tappedNode = gridContainer.nodes(at: locationInGrid).first(where: { $0.name?.contains("block_") == true }) {
            if let name = tappedNode.name,
               let index = Int(name.replacingOccurrences(of: "block_", with: "")) {
                
                uiDelegate?.didTapBlock(index)
                return true
            }
        }
        return false
    }
    
    func updateBlockLayer(at index: Int, to newLayer: Int) {
        guard index < blocks.count, index < blockNodes.count else { return }
        
        blocks[index].layer = newLayer
        
        if blocks[index].cleared {
            blockNodes[index].texture = nil
            blockNodes[index].color = .black.withAlphaComponent(0.3)
            addCheckmark(to: blockNodes[index])
        } else {
            blockNodes[index].texture = textureForLayer(layer: newLayer, index: index)
        }
    }
    
    private func addCheckmark(to node: SKNode) {
        if node.children.contains(where: { $0 is SKLabelNode }) { return }
        
        let check = SKLabelNode(text: "✓")
        check.fontName = "Arial-BoldMT"
        check.fontSize = 38
        check.zPosition = 10
        check.position = CGPoint(x: 0, y: -10)
        node.addChild(check)
    }
    
    func resetGrid() {
        blocks = Array(repeating: GridBlock(), count: rows * cols)
        setupGrid()
    }
}

