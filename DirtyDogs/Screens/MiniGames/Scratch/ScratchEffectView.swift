//
//  ScratchEffectView.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 09/12/25.
//


struct ScratchEffectView: View {
    let id = UUID()
    let position: CGPoint

    var body: some View {
        LottieView(
            name: "diggSmoke",   // nome do seu JSON
            loopMode: .playOnce
        ) {
            // Quando a animação termina → remover
            NotificationCenter.default.post(
                name: .removeScratchFX,
                object: id
            )
        }
        .frame(width: 80, height: 80)
        .position(position)
        .allowsHitTesting(false)
    }
}

extension Notification.Name {
    static let removeScratchFX = Notification.Name("removeScratchFX")
}
