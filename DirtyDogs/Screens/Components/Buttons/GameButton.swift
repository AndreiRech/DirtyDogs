//
//  PlayButton.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 27/11/25.
//

import SwiftUI

enum ButtonSize {
    case small
    case large
    
    var width: CGFloat {
        switch self {
        case .small: return 200
        case .large: return 360
        }
    }
    
    var height: CGFloat { 87.11 }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 18
        case .large: return 22
        }
    }
    
    var backgroundImage: String {
        switch self {
        case .small: return "buttonBG"
        case .large: return "buttonBGLarge"
        }
    }
    
    var noiseImage: String {
        switch self {
        case .small: return "buttonNoiseBG"
        case .large: return "buttonNoiseBGLarge"
        }
    }
    
    var noiseWidth: CGFloat {
        switch self {
        case .small: return 200
        case .large: return 327
        }
    }
}

struct GameButton: View {
    var title: String = "play"
    var disabled: Bool = false
    var size: ButtonSize = .small
    var action: () -> Void
    
    @State private var isPressed = false
    
    private let strokeWidth: CGFloat = 5.11
    
    private let springAnimation = Animation.spring(response: 0.25, dampingFraction: 0.6)
    
    private let textSpringAnimation = Animation.spring(response: 0.2, dampingFraction: 0.7)
    
    private let fadeAnimation = Animation.easeOut(duration: 0.15)
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Border
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(Color.darkCoffee, lineWidth: strokeWidth)
                    .frame(
                        width: isPressed ? size.width : size.width + 2,
                        height: isPressed ? size.height + 5 : size.height + 9
                    )
                    .offset(y: isPressed ? 1 : (size == .small ? 2.3 : 4))
                    .animation(springAnimation, value: isPressed)
                
                // Background Image
                Image(size.backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .shadow(color: .black.opacity(0.25), radius: 1.6, x: 0, y: isPressed ? 1.5 : 3.40)
                    .offset(y: isPressed ? 2 : 5.88)
                    .animation(springAnimation, value: isPressed)
                
                // Noise Overlay
                Image(size.noiseImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.noiseWidth, height: size.height)
                    .opacity(isPressed ? 0.8 : 1)
                    .animation(fadeAnimation, value: isPressed)
                
                // Title Text
                Text(title)
                    .font(.machineGunk(48))
                    .foregroundColor(.darkCoffee)
                    .offset(y: isPressed ? 2 : 0)
                    .animation(textSpringAnimation, value: isPressed)
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
    GameButton(title: "return to menu", size: .large, action: {})
}
