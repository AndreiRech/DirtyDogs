//
//  WindMiniGameView.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import SwiftUI

struct WindMiniGameView: View {
    @State var viewModel: WindMiniGameViewModelProtocol

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Assopre!")
                    .foregroundColor(.white)
                    .font(.machineGunk(32))

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 5)
                        .frame(width: 200, height: 200)

                    ForEach(viewModel.particles) { p in
                        Circle()
                            .fill(Color.white.opacity(p.opacity))
                            .frame(width: p.size, height: p.size)
                            .offset(x: p.x, y: p.y)
                    }

                    Circle()
                        .fill(.cyan)
                        .frame(width: 70, height: 70)
                        .offset(y: viewModel.balloonOffset)
                        .animation(.easeOut(duration: 0.12),
                                   value: viewModel.balloonOffset)
                }
                .frame(height: 330)

                ProgressView(
                    value: Double(min(viewModel.centerProgress, 1.2)),
                    total: 1.2
                )
                .tint(.cyan)
                .frame(width: 180)
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
        .onDisappear { viewModel.cancel() }
    }
}
