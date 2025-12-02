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
    
    var hapticsService: HapticsServiceProtocol
    var entityManager: EntityManager!
    var fxManager: ScreenFXManager!
    var inputManager: InputManager!
    var spawnManager: SpawnManager!
    var gridManager: GridManager!
    var backgroundNode: SKSpriteNode?
    
    weak var uiDelegate: GameSceneDelegate? {
        didSet {
            gridManager?.uiDelegate = uiDelegate
        }
    }
    
    weak var inventoryDelegate: InventoryDelegate?
    
    init(matchManager: MatchManager, size: CGSize, hapticService: HapticsServiceProtocol) {
        self.matchManager = matchManager
        self.hapticsService = hapticService
        super.init(size: size)
        
        self.entityManager = EntityManager(scene: self)
        self.fxManager = ScreenFXManager(scene: self, entityManager: entityManager, hapticsService: hapticsService)
        self.inputManager = InputManager(scene: self, entityManager: entityManager, fxManager: fxManager)
        self.gridManager = GridManager(scene: self, fxManager: fxManager)
        self.spawnManager = SpawnManager(entityManager: entityManager, fxManager: fxManager, gridManager: gridManager)
    }
    
    public override convenience init(size: CGSize) {
        fatalError("Use GameScene(matchManager:size:) instead")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "background")
        bg.zPosition = -999
        bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(bg)
        
        backgroundNode = bg
        
        scaleMode = .resizeFill
        physicsWorld.gravity = .init(dx: 0, dy: -9.6)
        
        setupBorders()
        
        _ = gridManager.createMap(horizontal: 3, vertical: 4)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        inputManager.update()
        checkExits()
        checkBottomCollection()
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
            
            let imageName = (entity is Bomb) ? "Bomb" : "Bomb"
            let item = InventoryItem(imageName: imageName)
            
            inventoryDelegate?.didCollect(item: item)
            return true
        }
        return false
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.handleTouchesMoved(touches)
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        gridManager.handleDrag(at: location)
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
        
        backgroundNode?.size = self.size
        backgroundNode?.position = CGPoint(x: frame.midX, y: frame.midY)
        
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
    
    private func checkBottomCollection() {
        let entities = entityManager.getEntities()
        let isInventoryFull = inventoryDelegate?.isInventoryFull()
        
        for entity in entities {
            guard let node = entity.component(ofType: GKSKNodeComponent.self)?.node else { continue }
            
            let collectionLineY = frame.minY + 250
                        
            if node.position.y < collectionLineY && isInventoryFull == false {
                collect(entity: entity as! GameEntity)
            }
        }
    }
    
    private func collect(entity: GameEntity) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        entityManager.remove(entity: entity)
        
        let itemName: String
        switch entity {
        case is Bomb:
            itemName = "Bomb-Button"
        case is Seed:
            itemName = "Seed-Button"
        case is Poop:
            itemName = "Tint-Button"
        default:
            itemName = "Unknown"
        }
        
        let item = InventoryItem(imageName: itemName)
        
        inventoryDelegate?.didCollect(item: item)
    }
    
    private func exitSide(for node: SKNode, minExitVelocity velocity: CGFloat = 1) -> EdgeSide? {
        guard let body = node.physicsBody else { return nil }
        let accFrame = node.calculateAccumulatedFrame()
        
        if accFrame.minY > frame.maxY - 20, body.velocity.dy > velocity {
            return .top
        }
        
        return nil
    }
    
    func setupBorders() {
        self.physicsBody = nil
        var bodies = [SKPhysicsBody]()
        
        let isFull = inventoryDelegate?.isInventoryFull() ?? true
        
        if isFull {
            let bottomEdge = SKPhysicsBody(
                edgeFrom: CGPoint(x: frame.minX, y: frame.minY),
                to: CGPoint(x: frame.maxX, y: frame.minY)
            )
            bodies.append(bottomEdge)
        } else {
        }
        
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
        case is Seed:
            objectType = .seed
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
    
    // MARK: Delegate Functions
    func resetGameGrid() {
        gridManager.resetGrid()
    }
    
    func spawnItem(type: PhysicsObjectType) {
        let spawnPoint = CGPoint(
            x: frame.midX,
            y: frame.maxY - 100
        )
        spawnManager.spawnItem(at: spawnPoint, entity: type)
    }
    
    func revealItem(at index: Int) -> Reward? {
        gridManager.completeScratch(at: index)
    }
    
    func playSoundEffect(sound: SoundEffect) {
        fxManager.playHaptics(with: sound)
    }
}
