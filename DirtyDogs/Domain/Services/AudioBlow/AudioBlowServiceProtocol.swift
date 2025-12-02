//
//  AudioBlowServiceProtocol.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//



import SwiftUI

protocol AudioBlowServiceProtocol {
    func start(levelHandler: @escaping (CGFloat) -> Void)
    /// Remove o tap do microfone
    func stop()
}
