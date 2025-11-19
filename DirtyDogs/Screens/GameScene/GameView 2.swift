//
//  GameView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI
import Speech
import SpriteKit

struct GameView2: View {
    @State private var viewModel: GridViewModel
    
    @State private var delegateAdapter: GridGameDelegateAdapter? = nil
    
    let matchManager: MatchManager
    
    init(matchManager: MatchManager) {
        self.matchManager = matchManager
        _viewModel = State(initialValue: GridViewModel(matchManager: matchManager))
        _delegateAdapter = State(initialValue: GridGameDelegateAdapter(viewModel: _viewModel.wrappedValue))
    }
    
    var body: some View {
        ZStack {
            GridView(viewModel: viewModel)
            
            // Botão de sair
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        matchManager.endGame()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            matchManager.delegate = delegateAdapter
        }
    }
}

// Adapter para conectar o MatchManager ao GridViewModel
class GridGameDelegateAdapter: MatchManagerDelegate {
    weak var viewModel: GridViewModel?
    
    init(viewModel: GridViewModel) {
        self.viewModel = viewModel
    }
    
    func spawnObject(with data: PhysicsObjectData) {
        // Não usado neste contexto, mas necessário pelo protocolo
    }
    
//    func receiveBall(with data: BallTransferData) {
//        Task { @MainActor in
//            viewModel?.receiveBall(data: data)
//        }
//    }
}

#Preview {
    GameView2(matchManager: MatchManager())
}
