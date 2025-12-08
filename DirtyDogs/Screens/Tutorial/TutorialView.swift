//
//  TutorialView.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 04/12/25.
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: TutorialViewModelProtocol
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image("closeButton")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .padding(.horizontal, 16)
                }
            }
            .offset(y: 40)
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(1...viewModel.numberOfPages, id: \.self) { index in
                    CardView(
                        imageName: viewModel.getPage(for: index),
                        totalPages: viewModel.numberOfPages,
                        atualPage: index
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .offset(y: -60)
            
            Spacer()
        }
        .background(
            MovingBackground()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .padding(.horizontal, 16)
    }
}

#Preview {
    TutorialView(viewModel: TutorialViewModel())
}
