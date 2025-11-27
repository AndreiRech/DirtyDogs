//
//  AudioBlowService.swift
//  DirtyDogs
//
//  Created by Eduardo Ferrari on 27/11/25.
//

import Foundation
import AVFoundation

@MainActor
@Observable
class AudioBlowService: AudioBlowServiceProtocol {

    // MARK: - Propriedades
    private let engine = AVAudioEngine()
    private var levelHandler: ((CGFloat) -> Void)?
    private var isTapInstalled = false

    // THRESHOLD mais rígido para evitar sensibilidade extrema
    private let minDB: CGFloat = -20    // abaixo disso é ignorado
    private let dbRange: CGFloat = 15   // db acima do threshold para normalizar

    // MARK: - Inicialização (Engine sempre ativa)
    init() {
        Task { @MainActor in
            configureSession()
            warmupEngineIfNeeded()
        }
    }

    // MARK: - Configura sessão do microfone
    private func configureSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord,
                                         mode: .measurement,
                                         options: [.duckOthers, .allowBluetoothHFP])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Erro ao configurar sessão de áudio:", error)
        }
    }

    // MARK: - Mantém engine sempre ligada 
    private func warmupEngineIfNeeded() {
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                print("Erro ao iniciar engine:", error)
            }
        }
    }

    // MARK: - Start
    func start(levelHandler: @escaping (CGFloat) -> Void) {
        self.levelHandler = levelHandler
        installTapIfNeeded()
    }

    // MARK: - Instala TAP
    private func installTapIfNeeded() {
        if isTapInstalled { return }

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        isTapInstalled = true
    }

    // MARK: - Processa áudio (RMS → dB → nível)
    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)

        var sum: Float = 0
        for i in 0..<frameCount {
            sum += channelData[i] * channelData[i]
        }

        let rms = sqrt(sum / Float(frameCount))
        let db = 20 * log10(rms)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if CGFloat(db) < minDB {
                self.levelHandler?(0)
            } else {
                let normalized = min(1, (CGFloat(db) - minDB) / dbRange)
                self.levelHandler?(normalized)
            }
        }
    }

    // MARK: - Stop
    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        isTapInstalled = false
    }
}
