//
//  ConfigButton.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 03/12/25.
//

import SwiftUI

struct ConfigButton: View {
    @Binding var isActive: Bool
    let images: [String]
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive.toggle()
            }
        } label: {
            Image(isActive ? images[0] : images[1])
                .frame(width: 76, height: 56)
                .contentTransition(.opacity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(isActive ? .mediumGreen : .redBone)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.darkCoffee, lineWidth: 3)
                )
        }
    }
}

#Preview {
    ConfigButton(
        isActive: .constant(false),
        images: ["SoundButton", "SoundButtonDisabled"],
        onTap: {}
    )
}
