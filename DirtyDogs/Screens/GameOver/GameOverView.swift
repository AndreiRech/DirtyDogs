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
            Color(.green)
                .ignoresSafeArea()
            
            VStack() {
                Spacer()
                
                ForEach(Array(viewModel.screenTextLines.enumerated()), id: \.offset) { index, text in
                    Text(text)
                        .font(.machineGunk(120))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(index % 2 == 0 ? .softRed : .softBlue)
                }
                .padding(-26)
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.softGray.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.wine, lineWidth: 4)
                        )
                    
                    Image(.bone)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(40)
                }
                .frame(height: 200)
                
                Spacer()
                
                Button {
                    viewModel.returnToMenu()
                } label: {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Text("PLAY")
                                .font(.system(size: 44, weight: .heavy, design: .rounded))
                                .foregroundStyle(.wine)
                                .frame(maxWidth: .infinity)
                                .background(.white)
                            
                            Text("AGAIN")
                                .font(.system(size: 44, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .background(.wine)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.wine, lineWidth: 3))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.wine, lineWidth: 3))
                }
                .padding(.horizontal, 50)
                
                Spacer()
            }
            .padding(16)
        }
    }
}

#Preview {
    GameOverView(viewModel: GameOverViewModel(matchManager: MatchManager()))
}
