//
//  PlayButton.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 27/11/25.
//


import SwiftUI

struct GameButton: View {
    var title: String = "settings"
    var disabled: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.machineGunk(48))
                .foregroundColor(.darkCoffee)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.darkCoffee, lineWidth: 5.11)
                            .frame(width: 202,height: 96)
                            .offset(y: 2.3)
                        
                        Image("buttonBG")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 87.11)
                            .fixedSize()
                            .shadow(color: .black.opacity(0.25), radius: 1.61932, x: 0, y: 3.40)
                            .offset(y: 5.88)
                        
                        Image("buttonNoiseBG")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 87.11)
                            .fixedSize()
                        
                    }
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

#Preview {
    GameButton(title: "play", action: {
        
    })
}
