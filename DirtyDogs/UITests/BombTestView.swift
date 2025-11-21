//
//  BombTestView.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 18/11/25.
//

import SwiftUI
import SpriteKit

struct BombTestView: View {

    @State private var scene = BombTestScene()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                Spacer()

                Button {
                    scene.spawnAndExplodeTestBomb()
                } label: {
                    Text("💣 Testar Bomba")
                        .font(.title3)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear { scene.scaleMode = .resizeFill }
    }
}

#Preview { BombTestView() }
