//
//  GameView2.swift
//  DirtyDogs
//
//  Created by Júlia on 12/11/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @State private var gameScene: GameScene?
    @State private var selectedIndex: Int? = nil
    @State private var sceneDelegateProxy: SceneDelegateProxy? = nil
    
    let matchManager: MatchManager
    
    init(matchManager: MatchManager) {
        self.matchManager = matchManager
    }
    
    var body: some View {
        ZStack {
            
            // SpriteKit Scene (ocupa tela toda)
            if let gameScene = gameScene {
                SpriteView(scene: gameScene, options: [.allowsTransparency])
                    .ignoresSafeArea()
            } else {
                Color.clear
                    .ignoresSafeArea()
                    .onAppear {
                        createScene()
                    }
            }
            
            // UI sobre a cena
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    
                    Button("Resetar grade") {
                        if let scene = gameScene {
                            scene.blocks = Array(repeating: GridBlock(), count: 9)
                            scene.rebuildGrid()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Enviar bolinha") {
                        gameScene?.spawnAndSendBall()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    Button("Enviar bomba") {
                        // Spawn local da bomba
                        let spawnPoint = CGPoint(
                            x: gameScene?.frame.midX ?? 0,
                            y: (gameScene?.frame.maxY ?? 0) - 100
                        )
                        gameScene?.spawnBomb(at: spawnPoint)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.bottom, 40)
            }
        }
        
        // Sheet de escavação
        .sheet(item: Binding(
            get: { selectedIndex.map { SheetIndex(value: $0) } },
            set: { newVal in selectedIndex = newVal?.value }
        )) { sheet in
            ScratchView(
                viewModel: ScratchViewModel(
                    layer: gameScene?.blocks[sheet.value].layer ?? 0,
                    onComplete: {
                        let idx = sheet.value
                        let newLayer = (gameScene?.blocks[idx].layer ?? 0) + 1
                        gameScene?.updateBlockLayer(at: idx, to: newLayer)
                        selectedIndex = nil
                    },
                    onCancel: {
                        selectedIndex = nil
                    }
                )
            )
        }
        
        .onDisappear {
            matchManager.endGame(with: .quit)
        }
    }
    
    // MARK: - Criar GameScene
    private func createScene() {
        let proxy = SceneDelegateProxy(onTapBlock: { index in
            self.selectedIndex = index
        })
        self.sceneDelegateProxy = proxy
        
        let s = GameScene(
            matchManager: matchManager,
            size: UIScreen.main.bounds.size
        )
        
        s.scaleMode = .resizeFill
        s.uiDelegate = proxy
        
        // IMPORTANTE: Conectar o delegate do matchManager à scene
        matchManager.delegate = s
        
        self.gameScene = s
    }
}


// MARK: - Delegate que conecta SpriteKit → SwiftUI
class SceneDelegateProxy: GameSceneDelegate {
    
    let onTapBlock: (Int) -> Void
    
    init(onTapBlock: @escaping (Int) -> Void) {
        self.onTapBlock = onTapBlock
    }
    
    func didTapBlock(_ index: Int) {
        DispatchQueue.main.async {
            self.onTapBlock(index)
        }
    }
}


#Preview {
    GameView(matchManager: MatchManager())
}
