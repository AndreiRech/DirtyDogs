//
//  PoopTestView.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 21/11/25.
//

import SwiftUI
import SpriteKit

struct PoopTestView: View {

    @State private var scene = PoopTestScene()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                Spacer()

                Button {
                    scene.spawnAndExplodeTestPoop()
                } label: {
                    Text("💩 Explodir Cocô")
                        .font(.title3)
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    scene.spawnPoopOnly()
                } label: {
                    Text("🧻 Spawnar Cocô")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    scene.explodePoopAlone()
                } label: {
                    Text("💥 Explosão Sem Spawn")
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear { scene.scaleMode = .resizeFill }
    }
}

#Preview { PoopTestView() }
