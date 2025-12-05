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
    
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    let batchSize = 10
    let totalImages = 100
    
    var body: some View {
        ZStack {
            LottieView(
                name: "splash screen",
                loopMode: .playOnce,
                onComplete: {
                    //                    showHome = true
                    withAnimation(.easeIn(duration: 0.2)) {
                        showBackground = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
