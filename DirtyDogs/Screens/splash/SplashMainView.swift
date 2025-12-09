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
    @State private var showBackground = false
    
<<<<<<< HEAD
    let matchManager: MatchManager
    let hapticsService: HapticsServiceProtocol
    let settingsService: SettingsServiceProtocol
    
    init(matchManager: MatchManager, hapticsService: HapticsServiceProtocol, settingsService: SettingsServiceProtocol) {
        self.matchManager = matchManager
        self.hapticsService = hapticsService
        self.settingsService = settingsService
    }
    
    
        
=======
    let onFinished: () -> Void
    
>>>>>>> dev
    var body: some View {
        ZStack {
            LottieView(
                name: "splash screen",
                loopMode: .playOnce,
                onComplete: {
                    withAnimation(.easeIn(duration: 0.1)) {
                        showBackground = true
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
<<<<<<< HEAD
            }
            if showHome {
                MenuView(
                    viewModel: MenuViewModel(
                        matchManager: matchManager,
                        hapticsService: hapticsService,
                        settingsService: settingsService
                    )
                )
=======
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                            onFinished()
                        }
                    }
>>>>>>> dev
            }
        }
    }
}


#Preview {
<<<<<<< HEAD
    SplashToPawsView(matchManager: MatchManager(), hapticsService: HapticsService(), settingsService: SettingsService())
=======
    SplashToPawsView(onFinished: {})
>>>>>>> dev
}
