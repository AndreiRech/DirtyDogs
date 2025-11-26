//
//  ScratchView.swift
//  DirtyDogs
//
//  Created by júlia fazenda ruiz on 18/11/25.
//

import SwiftUI

struct ScratchView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ScratchViewModelProtocol
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            ZStack {
                Color.black.opacity(0.45).ignoresSafeArea()
                
                ZStack {
                    Image(viewModel.getImage(nextLayer: false))
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width * 0.8, height: size.height * 0.5)
                        .mask {
                            Canvas { context, size in
                                context.fill(
                                    Path(CGRect(origin: .zero, size: size)),
                                    with: .color(.white)
                                )
                                
                                for index in viewModel.clearedCells {
                                    if index < viewModel.gridPoints.count {
                                        let point = viewModel.gridPoints[index]

                                        let rect = CGRect(
                                            x: point.x - viewModel.brushRadius,
                                            y: point.y - viewModel.brushRadius,
                                            width: viewModel.brushRadius * 2,
                                            height: viewModel.brushRadius * 2
                                        )
                                        
                                        context.blendMode = .destinationOut
                                        context.fill(Path(ellipseIn: rect), with: .color(.black))
                                    }
                                }
                            }
                            .compositingGroup()
                        }
                    
                    Image(viewModel.getImage(nextLayer: true))
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width * 0.8, height: size.height * 0.5)
                        .zIndex(-1)
                    
                    
                    Image("CleaningBackground")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width * 0.92)
                        .offset(y: -10)
                        .allowsHitTesting(false)
                        .zIndex(-2)
                    
                    VStack {
                        Text("CLEANING: \(Int(viewModel.revealRatio * 108))%")
                            .font(.machineGunk(24))
                            .foregroundStyle(.hardBrown)
                            .offset(y: 10)
                        
                        Spacer()
                    }
                    .frame(height: size.height * 0.65)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let p = value.location
                            let rectWidth = size.width * 0.8
                            let rectHeight = size.height * 0.6
                            
                            let originX = (size.width - rectWidth) / 2
                            let originY = (size.height - rectHeight) / 4
                            
                            let localPoint = CGPoint(x: p.x - originX, y: p.y - originY)

                            let r2 = viewModel.brushRadius * viewModel.brushRadius
                            var changed = false
                            
                            for (i, point) in viewModel.gridPoints.enumerated() {
                                if !viewModel.clearedCells.contains(i) {
                                    let dx = point.x - localPoint.x
                                    let dy = point.y - localPoint.y
                                    
                                    if (dx*dx + dy*dy) <= r2 {
                                        viewModel.clearedCells.insert(i)
                                        changed = true
                                    }
                                }
                            }
                            if changed { viewModel.updateRevealRatio() }
                        }
                )
            }
            .onAppear {
                let scratchAreaSize = CGSize(width: size.width * 0.8, height: size.height * 0.5)
                viewModel.setupGrid(in: scratchAreaSize)
            }
            .onChange(of: viewModel.clearedCells) {
                if viewModel.wasCleared == false && viewModel.revealRatio >= viewModel.targetRevealRatio {
                    viewModel.wasCleared = true
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.25))
                        viewModel.onComplete()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ScratchView(viewModel: ScratchViewModel(layer: 0, isClear: true, onComplete: { print("") }, onCancel: { print("") }))
}
