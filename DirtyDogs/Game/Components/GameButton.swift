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
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.darkCoffee, lineWidth: 5.11)
                    .frame(width: isPressed ? 200 : 202, height: isPressed ? 92 : 96)
                    .offset(y: isPressed ? 1 : 2.3)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
                
                Image("buttonBG")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 87.11)
                    .shadow(color: .black.opacity(0.25), radius: 1.6, x: 0, y: isPressed ? 1.5 : 3.40)
                    .offset(y: isPressed ? 2 : 5.88)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
                
                Image("buttonNoiseBG")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 87.11)
                    .opacity(isPressed ? 0.8 : 1)
                    .animation(.easeOut(duration: 0.15), value: isPressed)
                
                Text(title)
                    .font(.machineGunk(48))
                    .foregroundColor(.darkCoffee)
                    .offset(y: isPressed ? 2 : 0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
            }
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(PressableStyle(isPressed: $isPressed))
        .disabled(disabled)
    }
}

struct PressableStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

#Preview {
    GameButton(title: "play", action: {})
}
