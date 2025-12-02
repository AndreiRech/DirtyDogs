//
//  InventorySlotView.swift
//  DirtyDogs
//
//  Created by Isadora Guerra on 27/11/25.
//
import SwiftUI
import Speech
import SpriteKit

struct InventorySlotView: View {
    var item: InventoryItem?
    var shouldAnimate: Bool
    var onTap: ((InventoryItem) -> Void)?
    
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            if let item = item {
                Button {
                    onTap?(item)
                } label: {
                    Image(item.imageName)
                        .resizable()
                        .frame(width: 86.44, height: 103.03)
                        .scaledToFit()
                }
            } else {
                Image(.button)
                    .resizable()
                    .frame(width: 86.44, height: 103.03)
                    .scaledToFit()
            }
        }
        .offset(y: 80)
        .scaleEffect(scale)
        .onChange(of: shouldAnimate) { old, new in
            if new {
                animate()
            }
        }
    }
    
    private func animate() {
        withAnimation(.easeOut(duration: 0.12)) {
            scale = 1.15
        }
        withAnimation(.easeIn(duration: 0.12).delay(0.12)) {
            scale = 1
        }
    }
}

