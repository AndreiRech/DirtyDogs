//
//  MovingBackground.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 27/11/25.
//

import SwiftUI
import Combine

struct MovingBackground: View {

    // CONFIGURAÇÃO
    let columns = 8
    let rows = 24
    let spacing: CGFloat = 24
    let pawSize: CGFloat = 62
    let velocity: CGFloat = 0.5 /// ajuste a velocidade

    var itemHeight: CGFloat { pawSize + spacing }
    var loopLength: CGFloat { itemHeight * CGFloat(rows) }

    @State private var timers: [AnyCancellable] = []
    @State private var positions: [ScrollPosition] = []

    init() {
        _positions = State(initialValue: Array(repeating: ScrollPosition(), count: columns))
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<columns, id: \.self) { column in
                infiniteColumn(column)
            }
        }
        .background(backgroundNoise)
        .onAppear { startTimers() }
        .onDisappear { stopTimers() }
    }
}

// MARK: - COLUNAS

extension MovingBackground {

    @ViewBuilder
    func infiniteColumn(_ index: Int) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: spacing) {

                ForEach(0..<rows * 3, id: \.self) { row in
                    Image("paw")
                        .resizable()
                        .frame(width: pawSize, height: pawSize)
                        .opacity(0.27)
                        .blendMode(.softLight)
                        .rotationEffect(Angle(degrees: direction(for: index) == 1 ? 0 : 180))
                }
            }
            .padding(.vertical)
        }
        .scrollClipDisabled()
        .scrollPosition($positions[index])
        .onChange(of: positions[index].y ?? 0) { oldValue, newValue in
            handleLoop(for: index, newValue)
        }
    }
}

// MARK: - ANIMAÇÃO

extension MovingBackground {

    func direction(for column: Int) -> CGFloat {
        column % 2 == 0 ? 1 : -1
    }
    

    func startTimers() {
        stopTimers()
        timers = (0..<columns).map { column in
            Timer.publish(every: 0.01, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    let currentY = positions[column].y ?? 0
                    let newY = currentY + velocity * direction(for: column)
                    positions[column] = ScrollPosition(y: newY)
                }
        }
    }

    func stopTimers() {
        timers.forEach { $0.cancel() }
        timers.removeAll()
    }

    func handleLoop(for column: Int, _ value: CGFloat) {
        let limit = loopLength * 2

        if value > limit {
            positions[column] = ScrollPosition(y: loopLength)
        } else if value < 0 {
            positions[column] = ScrollPosition(y: loopLength)
        }
    }
}

// MARK: - FUNDO

extension MovingBackground {
    var backgroundNoise: some View {
        Image("noise")
            .resizable()
            .scaledToFill()
            .background(.black.opacity(0.1))
            .background(Color.mocca)
            .ignoresSafeArea()
    }
}

#Preview {
    MovingBackground()
}
