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
    
    let onFinished: () -> Void
    
    var body: some View {
        ZStack {
            LottieView(
                name: "splash screen",
                loopMode: .playOnce,
                onComplete: {
                    withAnimation(.easeIn(duration: 0.2)) {
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
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onFinished()
                        }
                    }
            }
        }
    }
}


#Preview {
    SplashToPawsView(onFinished: {})
}
