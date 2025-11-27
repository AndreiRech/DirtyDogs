//
//  GridManager.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 23/11/25.
//

import SpriteKit
import GameplayKit

class GridManager {
    weak var scene: GameScene?
    weak var uiDelegate: GameSceneDelegate?
    var fxManager: ScreenFXManager?
    
    var blocks: [GridBlock] = []
    var blockNodes: [SKSpriteNode] = []
    var gridContainer: SKNode
    
    private let rows = 4
    private let cols = 3
    private let spacing: CGFloat = -4
    private var blockSize: CGSize = .zero
    private var lastDraggedIndex: Int?
    
    init(scene: GameScene, fxManager: ScreenFXManager? = nil) {
        self.scene = scene
        self.fxManager = fxManager
        
        self.gridContainer = SKNode()
        self.gridContainer.zPosition = 10
        scene.addChild(gridContainer)
    }
    
    func setupGrid() {
        guard let scene = scene else { return }
        
        let availableWidth = scene.frame.width - (CGFloat(cols - 1) * spacing) - 16
        let availableHeight = scene.frame.height - 400 - (CGFloat(rows - 1) * spacing)
        
        let blockWidth = availableWidth / CGFloat(cols)
        let blockHeight = availableHeight / CGFloat(rows)
        
        blockSize = CGSize(width: blockWidth, height: blockHeight)
        
        blockNodes.forEach { $0.removeFromParent() }
        blockNodes.removeAll()
        gridContainer.removeAllChildren()
        
        let background = SKSpriteNode(imageNamed: "background2")
        background.size = CGSize(
            width: CGFloat(cols) * blockSize.width + CGFloat(cols - 1) * spacing + 20,
            height: CGFloat(rows) * blockSize.height + CGFloat(rows - 1) * spacing + 20
        )
        background.position = CGPoint(x: scene.frame.midX, y: scene.frame.maxY - 150 - background.size.height / 2)
        background.zPosition = -1
        gridContainer.addChild(background)
        
        let totalWidth = CGFloat(cols) * blockSize.width + CGFloat(cols - 1) * spacing
        let startX = scene.frame.midX - totalWidth / 2 + blockSize.width / 2
        let startY = scene.frame.maxY - 160 - blockSize.height / 2
        
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
                
                gridContainer.addChild(node)
                blockNodes.append(node)
            }
        }
    }
    
    func createMap(horizontal cols: Int, vertical rows: Int) -> [GridBlock] {
        // Deve sempre existir 3 ossos
        //  - 0 na camada 0 (grama)
        //  - 1 na camada 1 (terra)
        //  - 2 na camada 2 (pedra)
        // Para os itens, deve existir entre 2 até 3 de cada e devem ser espalhados pelas 3 camadas
        // Para o restante, deve ser .none
        
        let totalBlocks = cols * rows
        var newBlocks = Array(repeating: GridBlock(reward: .none, rewardLayer: 0), count: totalBlocks)
        var availableIndices = Array(0..<totalBlocks).shuffled()
        
        let boneDepths = [1, 2, 2]
        for depth in boneDepths {
            if let index = availableIndices.popLast() {
                newBlocks[index].reward = .bone
                newBlocks[index].rewardLayer = depth
            }
        }
        
        let possibleItems: [Reward] = [.bomb, .poop, .seed]
        
        for item in possibleItems {
            let itemCount = Int.random(in: 3...6)
            for _ in 0..<itemCount {
                if let index = availableIndices.popLast() {
                    let randomDepth = Int.random(in: 0...2)
                    
                    newBlocks[index].reward = item
                    newBlocks[index].rewardLayer = randomDepth
                }
            }
        }
        
        updateData(blocks: newBlocks)
        
        return self.blocks
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
            return SKTexture(imageNamed: isEven ? "obsidiam1" : "obsidiam2")
        }
    }
    
    func handleTouch(_ touch: UITouch) -> Bool {
        guard let scene = scene else { return false }
        let locationInScene = touch.location(in: scene)
        let locationInGrid = scene.convert(locationInScene, to: gridContainer)
        
        if let tappedNode = gridContainer.nodes(at: locationInGrid).first(where: { $0.name?.contains("block_") == true }) {
            if let name = tappedNode.name,
               let index = Int(name.replacingOccurrences(of: "block_", with: "")) {
                
                fxManager?.shakeSquare(node: tappedNode)
                fxManager?.playHaptics(with: .gridTouch)
                uiDelegate?.didTapBlock(index)
                return true
            }
            
        }
        return false
    }
    
    func completeScratch(at index: Int) -> Reward? {
        guard index < blocks.count else { return nil }
        
        blocks[index].layer += 1
        let block = blocks[index]
        
        updateBlockLayer(at: index, to: block.layer)
        
        if block.reward != .none && block.rewardLayer == block.layer - 1 {
            switch block.reward {
            case .bone:
                return .bone
            case .bomb, .poop, .seed:
                return block.reward
            default :
                break
            }
        }
        
        return nil
    }
    
    func updateBlockLayer(at index: Int, to newLayer: Int) {
        guard index < blocks.count, index < blockNodes.count else { return }
        
        blocks[index].layer = newLayer
        
        let node = blockNodes[index]
        
        node.color = .clear
        // Natural growth animation for the new layer
        let newTexture = textureForLayer(layer: newLayer, index: index)
        
        let growNode = SKSpriteNode(texture: newTexture)
        growNode.size = node.size
        growNode.position = .zero
        growNode.zPosition = node.zPosition + 1
        growNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        growNode.yScale = 0.0
        node.addChild(growNode)
        
        let growAction = SKAction.scaleY(to: 1.0, duration: 0.25)
        growNode.run(growAction) {
            node.texture = newTexture
            growNode.removeFromParent()
        }
        
    }
    
    func resetGrid() {
        blocks = createMap(horizontal: rows, vertical: cols)
        setupGrid()
    }
    
    func updateData(blocks: [GridBlock]) {
        self.blocks = blocks
        setupGrid()
    }
    
    func handleDrag(at position: CGPoint) {
        let locationInGrid = scene?.convert(position, to: gridContainer) ?? .zero
        
        if let draggedNode = gridContainer.nodes(at: locationInGrid).first(where: { $0.name?.contains("block_") == true }),
           let name = draggedNode.name,
           let index = Int(name.replacingOccurrences(of: "block_", with: "")), index != lastDraggedIndex {
            
            fxManager?.shakeSquare(node: draggedNode)
            fxManager?.playHaptics(with: .gridTouch)
            lastDraggedIndex = index
        }
        
    }
}
