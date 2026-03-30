//
//  RewardOverlay.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 30/03/26.
//

import SwiftUI
import Lottie

struct RewardOverlay: View {
    var reward: Reward
    var isAnimating: Bool
    var lightX: CGFloat
    var lightY: CGFloat
    var rewardImage: String
    var onAppear: () -> Void
    
    var body: some View {
        ZStack {
            if reward == .none {
                ZStack {
                    Image("NoneBackground")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 64)
                    
                    Text("YOU DIDN'T FIND\nANY ITEMS, TRY AGAIN!")
                        .font(.machineGunk(20))
                        .foregroundStyle(Color.brown)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                VStack {
                    Image(rewardImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .background(
                            ZStack {
                                LottieView(
                                    name: "rewardAnimation",
                                    loopMode: .loop,
                                    onComplete: nil
                                )
                                .frame(width: 200, height: 200)
                                .scaleEffect(1.3)
                                .allowsHitTesting(false)
                                .clipped()
                                
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [.white, .white.opacity(0.0)],
                                                center: .center, startRadius: 0, endRadius: 55
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .blur(radius: 5)
                                    
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [.white.opacity(0.6), .white.opacity(0.0)],
                                                center: .center, startRadius: 30, endRadius: 80
                                            )
                                        )
                                        .frame(width: 160, height: 160)
                                        .blur(radius: 20)
                                }
                                .scaleEffect(isAnimating ? 1.15 : 0.85)
                                .opacity(isAnimating ? 1.0 : 0.6)
                            }
                        )
                        .overlay(
                            Image("light-animation-reward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .offset(x: lightX, y: lightY)
                                .blendMode(.screen)
                                .mask(Image(rewardImage).resizable().scaledToFit())
                        )
                }
                .onAppear {
                    onAppear()
                }
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
}
