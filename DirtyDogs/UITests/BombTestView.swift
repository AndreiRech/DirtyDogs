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

            VStack {
                Spacer()

                Button {
                    scene.spawnAndExplodeTestBomb()
                } label: {
                    Text("Testar Explosão 💣")
                        .font(.title2)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            scene.scaleMode = .resizeFill
        }
    }
}

#Preview {
    BombTestView()
}
