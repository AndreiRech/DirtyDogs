//
//  TutorialView.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 04/12/25.
//

import SwiftUI

struct TutorialView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack (alignment: .center) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image("closeButton")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .padding()
                }
            }
            CardView(
                imageName: "Grass-Light",
                totalPages: 3,
                atualPage: 2
            )
            
            Spacer()
            
        }
        .background(
            MovingBackground()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .padding(.top, 32)
    }
}

#Preview {
    TutorialView()
}
