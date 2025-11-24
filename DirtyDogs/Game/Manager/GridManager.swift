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
    
    var blocks: [GridBlock] = Array(repeating: GridBlock(), count: 9)
    private var blockNodes: [SKSpriteNode] = []
    private var gridContainer: SKNode!
    
    private let rows = 3
    private let cols = 3
    private let spacing: CGFloat = 12
    private let blockSize = CGSize(width: 110, height: 110)
    
    init(scene: SKScene) {
        self.scene = scene
        self.gridContainer = SKNode()
        self.gridContainer.zPosition = 10
        scene.addChild(gridContainer)
    }
    
    func setupGrid() {
        guard let scene = scene else { return }
        
        blockNodes.forEach { $0.removeFromParent() }
        blockNodes.removeAll()
        gridContainer.removeAllChildren()
        
        let totalWidth = CGFloat(cols) * blockSize.width + CGFloat(cols - 1) * spacing
        let startX = scene.frame.midX - totalWidth / 2 + blockSize.width / 2
        let startY = scene.frame.maxY - 200 - blockSize.height / 2
        
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
                node.zPosition = 1
                
                let border = SKShapeNode(rectOf: blockSize, cornerRadius: 20)
                border.strokeColor = .white.withAlphaComponent(0.15)
                border.lineWidth = 2
                border.zPosition = 2
                node.addChild(border)
                
                if blocks[index].cleared {
                    addCheckmark(to: node)
                }
                
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
            blockNodes[index].texture = textureForLayer(newLayer)
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
        blocks = Array(repeating: GridBlock(), count: 9)
        setupGrid()
    }
}
