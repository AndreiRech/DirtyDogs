//
//  InventoryCollectDelegate.swift.swift
//  DirtyDogs
//
//  Created by Isadora Ferreira Guerra on 18/11/25.
//

import Foundation

protocol InventoryDelegate: AnyObject {
    func didCollect(item: InventoryItem)
    func didUse(item: InventoryItem)
}
