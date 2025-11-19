//
//  GameOverView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI

struct GameOverView: View {
    @State var viewModel: GameOverViewModelProtocol
    
    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: -32) {
                    Text(viewModel.getScreenText())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.label))
                }
                .padding(.bottom, 50)
                
                Button {
                    viewModel.returnToMenu()
                } label: {
                    Text("Return")
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding()
                .background(Capsule().fill(.green))
                
                Spacer()
            }
        }
    }
}

#Preview {
    GameOverView(viewModel: GameOverViewModel(matchManager: MatchManager()))
}
