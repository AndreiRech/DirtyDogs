//
//  PlayButton.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 27/11/25.
//


import SwiftUI

struct GameButton: View {
    var title: String = "PLAY"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.machineGunk(48))
                .foregroundColor(.darkCoffee)
                .padding()
                .background(
                    ZStack {
                        // Fundo principal
                        RoundedRectangle(cornerRadius: 26)
                            .fill(.caramelo)
                        
                        // Borda mais escura
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(.darkCoffee, lineWidth: 8)
                        
                        // Sombra interna simulando profundidade
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(.raspaCafe, lineWidth: 14)
                            .blur(radius: 6)
                            .offset(y: 4)
                            .mask(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(LinearGradient(
                                        colors: [.black, .clear],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    ))
                            )
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: 26))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameButton(title: "Play", action: {
        
    })
}
