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
        VStack {
            Spacer()
            
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .padding(30)
                .foregroundStyle(Color.green)
            
            Spacer()
            
            Button {
                viewModel.playButtonTapped()
            } label: {
                Text("Play")
                    .foregroundStyle(Color(.secondarySystemBackground))
                    .font(.machineGunk(32))
                    .bold()
            }
            .disabled(viewModel.isPlayButtonDisabled)
            .padding(.vertical, 20)
            .padding(.horizontal, 100)
            .background(
                Capsule()
                    .fill(
                        viewModel.isPlayButtonDisabled
                        ? .gray : .green
                    )
            )
            
            Text(viewModel.authenticatingState.rawValue)
                .foregroundStyle(Color(.label))
                .font(.headline)
                .fontWeight(.semibold)
                .padding()
            
            Spacer()
        }
        .background(
            Color(.secondarySystemBackground)
        )
        .ignoresSafeArea()
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
