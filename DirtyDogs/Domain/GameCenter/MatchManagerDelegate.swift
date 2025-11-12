//
//  MatchManagerDelegate.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation

protocol MatchManagerDelegate: AnyObject {
    func spawnBall(at point: CGPoint, from side: EdgeSide)
}
