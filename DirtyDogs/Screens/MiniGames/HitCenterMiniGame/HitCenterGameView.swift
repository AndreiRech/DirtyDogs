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
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Acerte os 3 alvos!")
                    .foregroundColor(.white)
                    .font(.machineGunk(32))

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 4)
                        .frame(width: 240, height: 240)

                    ForEach(0..<3, id: \.self) { i in
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
                
                Button {
                    viewModel.tap()
                } label: {
                    Text("BATER!")
                        .font(.machineGunk(32))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 48)
                        .background(Color.brown)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 3)
                        )
                }
                .padding(.top, 40)
            }
            .opacity(viewModel.showResult ? 0 : 1)
            
            if viewModel.showResult {
                RewardOverlay(
                    reward: viewModel.reward,
                    isAnimating: viewModel.isAnimating,
                    lightX: viewModel.lightX,
                    lightY: viewModel.lightY,
                    rewardImage: viewModel.getRewardImage(),
                    onAppear: {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            viewModel.isAnimating = true
                        }
                        viewModel.startLightSweep(size: 50)
                    }
                )
                .zIndex(100)
            }
        }
        .onAppear { viewModel.start() }
    }
}

#Preview {
    HitCenterMiniGameView(viewModel: HitCenterMiniGameViewModel(layer: 1, reward: .bomb, onComplete: {}, playHaptics: {}))
}
