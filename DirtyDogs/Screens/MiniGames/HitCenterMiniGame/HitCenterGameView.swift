//
//  HitCenterGameView.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import SwiftUI

struct HitCenterMiniGameView: View {

    @State var viewModel: HitCenterMiniGameViewModelProtocol

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {

                Text("Acerte os 3 alvos!")
                    .foregroundColor(.white)
                    .font(.largeTitle.bold())

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 4)
                        .frame(width: 240, height: 240)

                    ForEach(0..<3) { i in
                        let t = viewModel.targetAngles[i] * .pi / 180
                        Circle()
                            .fill(viewModel.hitTargets[i] ? .green : .red)
                            .frame(width: 44, height: 44)
                            .offset(
                                x: cos(t) * 120,
                                y: sin(t) * 120
                            )
                    }

                    Circle()
                        .fill(.cyan)
                        .frame(width: 32, height: 32)
                        .offset(
                            x: cos(viewModel.angle * .pi/180) * 120,
                            y: sin(viewModel.angle * .pi/180) * 120
                        )
                }
                .frame(width: 260, height: 260)
                .onTapGesture { viewModel.tap() }
            }
        }
        .onAppear { viewModel.start() }
    }
}
