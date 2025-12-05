//
//  splashView.swift
//  DirtyDogs
//
//  Created by Isadora Guerra on 04/12/25.
//

import SwiftUI
import Combine

struct RandomImage: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
}

struct ContentView: View {
    @State private var images: [RandomImage] = []
    
    // Timer rápido (20 vezes por segundo)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // Quantas patinhas adicionar por tick
    let batchSize = 10
    
    // Total desejado
    let totalImages = 500
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("Fundo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                ForEach(images) { image in
                    Image("patinha")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: image.size, height: image.size)
                        .position(image.position)
                }
            }
            .onReceive(timer) { _ in
                if images.count < totalImages {
                    addBatch(in: geometry.size)
                }
            }
        }
    }
    
    // Adiciona várias patinhas por vez
    func addBatch(in size: CGSize) {
        for _ in 0..<batchSize {
            guard images.count < totalImages else { break }

            let randomX = CGFloat.random(in: 0...size.width)
            let randomY = CGFloat.random(in: 0...size.height)
            let randomSize = CGFloat.random(in: 40...150)  // mínimo maior
            
            let newImage = RandomImage(
                position: CGPoint(x: randomX, y: randomY),
                size: randomSize
            )
            
            images.append(newImage)
        }
    }
}

#Preview {
    ContentView()
}
