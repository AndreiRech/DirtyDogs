//
//  VolumeButtonService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct VolumeButtonService: UIViewRepresentable, VolumeButtonServiceProtocol {
    private var matchManager: MatchManager
    
    init(matchManager: MatchManager) {
        self.matchManager = matchManager
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.isHidden = false
        volumeView.alpha = 0.001
        view.addSubview(volumeView)
        
        context.coordinator.startObserving(matchManager: matchManager)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.stopObserving()
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject {
        private var audioSession = AVAudioSession.sharedInstance()
        private var isObserving = false
        private weak var matchManager: MatchManager?

        func startObserving(matchManager: MatchManager) {
            self.matchManager = matchManager
            guard !isObserving else { return }

            do {
                try audioSession.setActive(true)
                audioSession.addObserver(self, forKeyPath: "outputVolume", options: [.old, .new], context: nil)
                isObserving = true
            } catch {
                print("Erro ao ativar a sessão de áudio: \(error)")
            }
        }

        func stopObserving() {
            guard isObserving else { return }
            
            audioSession.removeObserver(self, forKeyPath: "outputVolume")
            
            do {
                try audioSession.setActive(false)
            } catch {
                 print("Erro ao desativar a sessão de áudio: \(error)")
            }
            isObserving = false
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "outputVolume",
               let change = change,
               let newValue = change[.newKey] as? Float,
               let oldValue = change[.oldKey] as? Float {
                
                if newValue > oldValue {
                    Task { @MainActor in
                        // TODO: Adicionar ação
                        print("volume decrementado")
                    }
                } else if newValue < oldValue {
                    Task { @MainActor in
                        // TODO: Adicionar ação
                        print("volume decrementado")
                    }
                }
            }
        }
    }
}
