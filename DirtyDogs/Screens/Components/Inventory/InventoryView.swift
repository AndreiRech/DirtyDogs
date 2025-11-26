//
//  InventoryView.swift
//  DirtyDogs
//
//  Created by Isadora Ferreira Guerra on 24/11/25.
//

import SwiftUI
import Speech
import SpriteKit
//import SVGKit

struct InventoryView: View {
    var bonesFound: Int
    var availableItems: [InventoryItem?]
    
    var body: some View {
        ZStack{
            Image(.inventoryBackground)
                .resizable()
                .frame(width: 295, height: 115)
                .scaledToFit()
            
            BoneBarView(boneBarStatus: BoneStatusEnum(rawValue: bonesFound) ?? .empty)
                .offset(y: -30)
            
            ZStack{
                Image("Chon")
                    .resizable()
                    .frame(width: 303, height: 145)
                    .scaledToFit()
                    .offset(y: 65)
                
                Image(.itemsLabel)
                    .offset(y: 12)
                
                HStack{
                    ForEach(availableItems.indices, id: \.self) { index in
                        if let item = availableItems[index] {
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 86.44, height: 103.03)
                                .scaledToFit()
                                .offset(y: 80)
                        } else {
                            Image(.button)
                                .resizable()
                                .frame(width: 86.44, height: 103.03)
                                .scaledToFit()
                                .offset(y: 80)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InventoryView(bonesFound: 3, availableItems: [InventoryItem(imageName: "seed")])
}
