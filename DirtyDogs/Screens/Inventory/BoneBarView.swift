//
//  BoneBarView.swift
//  DirtyDogs
//
//  Created by Isadora Ferreira Guerra on 24/11/25.
//

import SwiftUI
import Speech
import SpriteKit
//import SVGKit

enum BoneStatusEnum: Int {
    case empty = 0
    case half = 1
    case full = 2
}

struct BoneBarView: View {
    let boneBarStatus: BoneStatusEnum;
    
    var body: some View {
        if(boneBarStatus == .empty){
            ZStack{
                GeometryReader { geo in
                    Image("BoneBarEmpty")

                    Image("BoneEmpty")
                        .position(
                            x: geo.size.width / 3,   // 👉 1/3 da largura
                        )
                }
            }
        } else if (boneBarStatus == .half){
            
        } else {
            
        }
    }
}

#Preview {
    BoneBarView(boneBarStatus: .empty)
}
