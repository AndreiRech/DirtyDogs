//
//  BoneBarView.swift
//  DirtyDogs
//
//  Created by Isadora Ferreira Guerra on 24/11/25.
//

import SwiftUI
import Speech
import SpriteKit

struct BoneBarView: View {
    let boneBarStatus: BoneStatusEnum
    
    var body: some View {
        ZStack {
            Image("BoneBarEmpty")
                .resizable()
                .scaledToFit()
            
            GeometryReader { geo in
                switch boneBarStatus {
                case .empty:
                    Image("BoneEmpty")
                        .position(x: geo.size.width * 1/3, y: geo.size.height / 2)
                    Image("BoneEmpty")
                        .position(x: geo.size.width * 2/3, y: geo.size.height / 2)
                    Image("BoneEmpty")
                        .position(x: geo.size.width * 3/3, y: geo.size.height / 2)
                    
                case .firstHalf:
                    Image("whiteProgressBar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 3)
                        .position(x: geo.size.width / 6, y: geo.size.height / 2)
                    
                    Image("BoneFull")
                        .position(x: geo.size.width * 1/3, y: geo.size.height / 2)
                    Image("BoneEmpty")
                        .position(x: geo.size.width * 2/3, y: geo.size.height / 2)
                    Image("BoneEmpty")
                        .position(x: geo.size.width * 3/3, y: geo.size.height / 2)
                    
                case .secondHalf:
                    Image("whiteProgressBar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 3)
                        .position(x: geo.size.width / 6, y: geo.size.height / 2)
                    
                    Image("whiteProgressBar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 3)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    
                    Image("BoneFull")
                        .position(x: geo.size.width * 1/3, y: geo.size.height / 2)
                    Image("BoneFull")
                        .position(x: geo.size.width * 2/3, y: geo.size.height / 2)
                    Image("BoneEmpty")
                        .position(x: geo.size.width * 3/3, y: geo.size.height / 2)
                    
                case .full:
                    Image("whiteProgressBar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 3)
                        .position(x: geo.size.width / 6, y: geo.size.height / 2)
                    
                    Image("whiteProgressBar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 3)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    
                    Image("whiteProgressBar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 3)
                        .position(x: geo.size.width * (5.0 / 6.0), y: geo.size.height / 2)
                    
                    Image("BoneFull")
                        .position(x: geo.size.width * 1/3, y: geo.size.height / 2)
                    Image("BoneFull")
                        .position(x: geo.size.width * 2/3, y: geo.size.height / 2)
                    Image("BoneFull")
                        .position(x: geo.size.width * 3/3, y: geo.size.height / 2)
                }
            }
        }
        .frame(width: 235, height: 33)
    }
}

#Preview {
    VStack(spacing: 10) {
        BoneBarView(boneBarStatus: .empty)
        Spacer()
        
        BoneBarView(boneBarStatus: .firstHalf)
        Spacer()

        BoneBarView(boneBarStatus: .secondHalf)
        Spacer()

        BoneBarView(boneBarStatus: .full)
    }
    .padding()
}
