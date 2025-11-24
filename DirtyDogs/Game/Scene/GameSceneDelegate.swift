//
//  GameSceneDelegate.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 23/11/25.
//

protocol GameSceneDelegate: AnyObject {
    func didTapBlock(_ index: Int)
}

protocol InventoryDelegate: AnyObject {
    func didCollect(item: InventoryItem)
    func didUse(item: InventoryItem)
}
