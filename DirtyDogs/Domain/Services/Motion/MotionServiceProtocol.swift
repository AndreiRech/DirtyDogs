//
//  MotionServiceProtocol.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 21/11/25.
//

import Foundation

protocol MotionServiceProtocol {
    func startMonitoring(onShake: @escaping (Double) -> Void)
    func stopMonitoring()
}
