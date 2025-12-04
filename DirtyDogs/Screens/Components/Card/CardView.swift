//
//  CardView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 03/12/25.
//

import SwiftUI

struct CardView: View {
    let imageName: String
    let totalPages: Int
    var atualPage: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 304, height: 521)
                .zIndex(2)
            
            Image("OnboardingBackground")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 511)
                .zIndex(1)
            
            HStack {
                ForEach(1...totalPages, id: \.self) { page in
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(page == atualPage ? .darkCoffee : .raspaCafe)
                }
            }
            .zIndex(3)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    CardView(imageName: "Grass-Light", totalPages: 3, atualPage: 2)
}
