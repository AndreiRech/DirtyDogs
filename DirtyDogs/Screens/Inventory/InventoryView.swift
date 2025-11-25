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

    var body: some View {
        ZStack{
            Image("inventoryBackground")
                .resizable()
                .frame(width: 295, height: 115)
                .scaledToFit()
            
            BoneBarView(boneBarStatus: .firstHalf)
                .offset(y: -30)
            
            
            ZStack{
                Image("Chon")
                    .resizable()
                    .frame(width: 303, height: 145)
                    .scaledToFit()
                    .offset(y: 65)
                
                Text("Items")
                    .font(.custom("MachineGunk", size: 19))
                    .offset(y:10)
                
                HStack{
                    ForEach(0..<3){_ in
                        Image("Button")
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

#Preview {
    InventoryView()
}
