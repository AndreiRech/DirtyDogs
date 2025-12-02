//
//  PoopTestScene.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 21/11/25.
//

import SpriteKit
import GameplayKit
import CoreMotion

class PoopTestScene: GameScene {

    private let motionManager = CMMotionManager()
    private var shakeThreshold: Double = 2.0   // sensibilidade
    private var lastShakeTime = Date().timeIntervalSince1970
    var fx: ScreenFXManager? {fxManager}



    
    init() {
        let screenSize = UIScreen.main.bounds.size
        let matchManager = MatchManager()
        super.init(matchManager: matchManager, size: screenSize, hapticService: HapticsService())
        matchManager.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .black
        startShakeDetection()
    }

    /// Testa o cocô usando a nova arquitetura (executeAction cuida da explosão)
   func spawnAndExplodeTestPoop() {
       let center = CGPoint(x: frame.midX, y: frame.midY)
       if let spawn = spawnManager {
           let entity = Tint()
           entity.setPosition(to: center)
           entityManager.add(entity: entity)
           spawn.executeAction(value: entity)   //força a explosão
       }
   }


    func spawnPoopOnly() {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        spawnManager.spawnItem(at: center, entity: .tint)
    }

    func explodePoopAlone() {
        let fake = SKNode()
        fake.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(fake)
//        spawnManager.executeAction(value: fake)
    }
    
    private func startShakeDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.12
        let queue = OperationQueue.main
        
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            let ax = data.acceleration.x
            let ay = data.acceleration.y
            let az = data.acceleration.z
            
            let magnitude = sqrt(ax*ax + ay*ay + az*az)
            
            if magnitude > self.shakeThreshold {
                let now = Date().timeIntervalSince1970
                if now - self.lastShakeTime > 1.2 {
                    self.lastShakeTime = now
                    self.fx?.cleanPoopOverlayOnShake()
                }
            }
        }
    }



}

