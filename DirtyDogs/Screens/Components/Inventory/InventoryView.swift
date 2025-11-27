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
    var slotThatShouldAnimate: Int?
    
    var onItemTap: ((InventoryItem) -> Void)?
    
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
                    .frame(width: 303, height: 155)
                    .scaledToFit()
                    .offset(y: 70)
                
                Text("Items")
                    .font(.machineGunk(19))
                    .foregroundStyle(.hardBrown)
                    .offset(y: 10)
                
                HStack(alignment: .center){
                    ForEach(availableItems.indices, id: \.self) { index in
                        if let item = availableItems[index] {
                            Button {
                                onItemTap?(item)
                            } label: {
                                Image(item.imageName)
                                    .resizable()
                                    .frame(width: 86.44, height: 103.03)
                                    .scaledToFit()
                                    .offset(y: 82)
                            }
                        } else {
                            Image(.button)
                                .resizable()
                                .frame(width: 86.44, height: 103.03)
                                .scaledToFit()
                                .offset(y: 82)
                        }
//                        InventorySlotView(
//                            item: availableItems[index],
//                            shouldAnimate: slotThatShouldAnimate == index,
//                            onTap: onItemTap
//                        )
                    }
                }
            }
        }
    }
}

#Preview {
    InventoryView(bonesFound: 3, availableItems: [InventoryItem(imageName: "seed"), InventoryItem(imageName: "Bomb"), InventoryItem(imageName: "seed")])
}
