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

            VStack(spacing: 20) {

                Spacer()

                // 1. Teste completo: spawn + pavio + explosão + stun + shake + haptic
                Button {
                    scene.spawnAndExplodeTestBomb()
                } label: {
                    Text("💣 Testar Explosão Completa")
                        .font(.title3)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // 2. Spawn sem explodir
                Button {
                    scene.spawnBombOnly()
                } label: {
                    Text("🧨 Spawnar só a bomba")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // 3. Explodir sem spawn
                Button {
                    scene.explodeWithoutSpawn()
                } label: {
                    Text("💥 Explosão sem spawn")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // 4. Testar apenas tremor e haptic
                Button {
                    scene.testShakeOnly()
                } label: {
                    Text("📳 Testar Shake + Haptic")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer().frame(height: 40)
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
