//
//  GameScene.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SpriteKit
import GameplayKit
import GameKit

public class GameScene: SKScene {
    private var matchManager: MatchManager
    
    var entityManager: EntityManager!
    var fxManager: ScreenFXManager!
    var inputManager: InputManager!
    var spawnManager: SpawnManager!
    var gridManager: GridManager!
    
    weak var uiDelegate: GameSceneDelegate? {
        didSet {
            gridManager?.uiDelegate = uiDelegate
        }
    }
    weak var inventoryDelegate: InventoryDelegate?
    
    init(matchManager: MatchManager, size: CGSize) {
        self.matchManager = matchManager
        super.init(size: size)
        
        self.entityManager = EntityManager(scene: self)
        self.fxManager = ScreenFXManager(scene: self, entityManager: entityManager)
        self.inputManager = InputManager(scene: self, entityManager: entityManager, fxManager: fxManager)
        self.spawnManager = SpawnManager(entityManager: entityManager, fxManager: fxManager)
        self.gridManager = GridManager(scene: self) // NOVO
    }
    
    public override convenience init(size: CGSize) {
        fatalError("Use GameScene(matchManager:size:) instead")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        physicsWorld.gravity = .init(dx: 0, dy: -9.6)
        
        setupBorders()
        
        gridManager.setupGrid()
        
        // TODO: Remover isso quando não precisar de um item inicial
        let center = CGPoint(x: frame.midX, y: frame.midY)
        spawnManager.spawnItem(at: center, entity: .ball)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        inputManager.update()
        checkExits()
    }
    
    // MARK: - Touch Functions
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if inputManager.handleTouchesBegan(touches) {
            return
        }
        
        if handleCollectionTap(at: location) {
            return
        }
        
        if gridManager.handleTouch(touch) {
            return
        }
    }
    
    func handleCollectionTap(at location: CGPoint) -> Bool {
        guard let manager = entityManager else { return false }
        
        if let entity = manager.entity(at: location) {
            manager.remove(entity: entity)

            let imageName = (entity is Bomb) ? "mockItem" : "mockItem"
            let item = InventoryItem(imageName: imageName)
            
            inventoryDelegate?.didCollect(item: item)
            return true
        }
        return false
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.handleTouchesMoved(touches)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.handleTouchesEnded()
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.handleTouchesEnded()
    }
    
    public override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        guard let _ = self.view, gridManager != nil else { return }
        
        setupBorders()
        gridManager.setupGrid()
        
        children.filter { $0.name?.hasPrefix("sensor.") == true }.forEach {
            $0.removeFromParent()
        }
    }
    
    // MARK: - Physics & Logic
    private func checkExits() {
        let entities = entityManager.getEntities()
        
        for entity in entities {
            if let node = entity.component(ofType: GKSKNodeComponent.self)?.node {
                if let side = exitSide(for: node) {
                    sendParcel(side: side, node: node, entity: entity as! GameEntity)
                }
            }
        }
    }
    
    private func exitSide(for node: SKNode, minExitVelocity velocity: CGFloat = 1) -> EdgeSide? {
        guard let body = node.physicsBody else { return nil }
        let accFrame = node.calculateAccumulatedFrame()
        
        if accFrame.minY > frame.maxY - 20, body.velocity.dy > velocity {
            return .top
        }
        
        return nil
    }
    
    private func setupBorders() {
        self.physicsBody = nil
        var bodies = [SKPhysicsBody]()
        
        let bottomEdge = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.minY))
        bodies.append(bottomEdge)
        
        let leftEdge = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.minX, y: frame.maxY))
        bodies.append(leftEdge)
        
        let rightEdge = SKPhysicsBody(edgeFrom: CGPoint(x: frame.maxX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.maxY))
        bodies.append(rightEdge)
        
        let edgeBody = SKPhysicsBody(bodies: bodies)
        edgeBody.categoryBitMask = PhysicsCategory.edge
        
        edgeBody.isDynamic = false
        edgeBody.affectedByGravity = false
        edgeBody.allowsRotation = false
        
        self.physicsBody = edgeBody
    }
    
    private func sendParcel(side: EdgeSide, node: SKNode, entity: GameEntity) {
        if entity.getReceived() {
            spawnManager.executeAction(value: entity)
            entityManager.remove(entity: entity)
            return
        }
        
        entityManager.remove(entity: entity)
        
        var payload: PhysicsObjectData? = nil
        let xDirection: CGFloat = node.position.x
        let objectType: PhysicsObjectType?
        
        switch entity {
        case is Ball:
            objectType = .ball
        case is Bomb:
            objectType = .bomb
        case is Poop:
            objectType = .poop
        default:
            objectType = nil
            print("erro: entity type not found")
        }
        
        guard let objectType else { return }
        
        payload = PhysicsObjectData(
            objectType: objectType,
            x: xDirection,
            y: node.position.y,
            side: side
        )
        
        if let physicsData = payload {
            let packet = GamePacket(type: .spawnPhysicsObject, physicsData: physicsData)
            matchManager.sendPacket(packet, mode: .reliable)
        } else {
            print("AVISO: Entidade do tipo \(type(of: entity)) saiu da tela, mas não há lógica de rede para ela.")
        }
    }
    
    private func handleTap(at location: CGPoint) {
        guard let manager = entityManager else { return }
        
        if let entity = manager.entity(at: location) {
            manager.remove(entity: entity)
            
            let item = InventoryItem(imageName: "ball_icon")
            inventoryDelegate?.didCollect(item: item)
        }
    }
}
