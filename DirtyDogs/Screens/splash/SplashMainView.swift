//
//  SplashMainView.swift
//  DirtyDogs
//
//  Created by Isadora Guerra on 05/12/25.
//

import SwiftUI
import Combine
import Lottie

struct SplashToPawsView: View {
    @State private var showHome = false
    @State private var showBackground = false
        
    var body: some View {
        ZStack {
            LottieView(
                name: "splash screen",
                loopMode: .playOnce,
                onComplete: {
                    withAnimation(.easeIn(duration: 0.2)) {
                        showBackground = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            showHome = true
                        }
                    }
                }
            )
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if showBackground {
                Image(.fundo)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if showHome {
                MenuView(
                    viewModel: MenuViewModel(
                        matchManager: MatchManager(),
                        hapticsService: HapticsService(),
                        settingsService: SettingsService()
                    )
                )
            }
        }
        
    }
}


#Preview {
    SplashToPawsView()
}
