//
//  LottieView.swift
//  DirtyDogs
//
//  Created by Isadora Guerra on 05/12/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let onComplete: (() -> Void)?

    private let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        
        animationView.play { finished in
                    if finished {
                        onComplete?()
                    }
                }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    LottieView(name: "splash screen", loopMode: .playOnce, onComplete: nil)
               }
