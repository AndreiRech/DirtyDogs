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
    private let engine = AVAudioEngine()
    private var levelHandler: ((CGFloat) -> Void)?
    private var isTapInstalled = false

    private let minDB: CGFloat = -20
    private let dbRange: CGFloat = 15

    init() { }

    private func configureSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord,
                                         mode: .measurement,
                                         options: [.duckOthers, .allowBluetoothHFP, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Erro ao configurar sessão de áudio:", error)
        }
    }

    func start(levelHandler: @escaping (CGFloat) -> Void) {
        self.levelHandler = levelHandler
        
        configureSession()
        installTapIfNeeded()
        startEngineIfNeeded()
    }

    private func startEngineIfNeeded() {
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                print("Erro ao iniciar engine:", error)
            }
        }
    }

    private func installTapIfNeeded() {
        if isTapInstalled { return }

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        
        if format.sampleRate == 0 {
            return
        }

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        isTapInstalled = true
    }

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

    func stop() {
        if isTapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            isTapInstalled = false
        }
        
        if engine.isRunning {
            engine.stop()
        }
    }
}
