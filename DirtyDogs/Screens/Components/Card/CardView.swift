//
//  CardView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 03/12/25.
//

import SwiftUI

struct CardView: View {
    let imageName: String
    
    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 304, height: 386)
                .zIndex(2)
            
            Image("CleaningBackground")
                .resizable()
                .scaledToFit()
                .frame(width: 344, height: 460)
                .offset(y: -10)
                .zIndex(1)
        }
    }
}

#Preview {
    CardView(imageName: "Grass-Light")
}
