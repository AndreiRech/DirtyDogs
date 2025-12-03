//
//  MovingBackground.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 27/11/25.
//

import SwiftUI

struct MovingBackground: View {

    let columns = 8
    let spacing: CGFloat = 24
    let pawSize: CGFloat = 62
    let numberOfRows = 24
    let animationDuration: Double = 10
    var scrollDistance: CGFloat {
        self.pawSize + self.spacing
    }

    @State private var offsets: [CGFloat] = Array(repeating: 0, count: 8)


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fundo (Noise e Mocca)
                Image("noise")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.1))
                    .background(Color.mocca)
                    .ignoresSafeArea()

                // Grid de Patinhas
                HStack(spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { column in
                        LazyVStack(spacing: 24) {
                            ForEach(0..<numberOfRows, id: \.self) { row in
                                Image("paw")
                                    .resizable()
                                    .frame(width: pawSize, height: pawSize)
                                    .opacity(0.27)
                                    .blendMode(.softLight)
                            }
                        }
                        .offset(y: offsets[column])
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: -(CGFloat(columns) * (pawSize + spacing)) / 4.0, y: -200)
            }
        }
        .onAppear {
            if offsets.count != columns {
                offsets = Array(repeating: 0, count: columns)
            }
            startAnimation()
        }
    }

    func startAnimation() {
        for column in 0..<columns {
            let direction: CGFloat = column % 2 == 0 ? 1 : -1

            withAnimation(
                Animation
                    .linear(duration: animationDuration)
                    .repeatForever(autoreverses: false)
                    .delay(Double(column) * 0.1)
            ) {
                offsets[column] = direction * scrollDistance
            }
        }
    }
}

#Preview {
    MovingBackground()
}
