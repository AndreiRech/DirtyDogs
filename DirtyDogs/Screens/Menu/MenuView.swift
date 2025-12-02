//
//  MenuView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI
import CoreHaptics

struct MenuView: View {
    @State var viewModel: MenuViewModelProtocol
    
    var body: some View {
        
        ZStack {
            MovingBackground()
            
            VStack(spacing: 86) {
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))
                    .padding(.horizontal, 55)
                    .padding(.top, 40)
                
                
                VStack (spacing: 40){
                    GameButton (
                        title: "play",
                        disabled: viewModel.isPlayButtonDisabled
                    ){
                        viewModel.playButtonTapped()
                    }
                    
                    GameButton (title: "settings") {
                        // add open settings func
                    }
                }
                
                Spacer()
                
            }
            .padding(.top, 20)
        }
        .onAppear {
            viewModel.prepareHaptics()
        }
    }
}

#Preview {
    MenuView(
        viewModel: MenuViewModel(
            matchManager: MatchManager(),
            hapticsService: HapticsService()
        )
    )
}
