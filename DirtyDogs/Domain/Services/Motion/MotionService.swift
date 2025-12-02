//
//  MotionService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 21/11/25.
//

import CoreMotion

class MotionService: MotionServiceProtocol {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private let shakeThreshold: Double = 1.5

    func startMonitoring(onShake: @escaping (Double) -> Void) {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdates(to: queue) { (data, error) in
            guard let data = data, error == nil else { return }
            
            let acceleration = data.acceleration
            let magnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
            
            if magnitude > self.shakeThreshold {
                let intensity = magnitude - self.shakeThreshold
                
                Task { @MainActor in
                    onShake(intensity)
                }
            }
        }
    }

    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
    }
}
