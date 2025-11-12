//
//  SpeechService.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import Foundation
import Speech

@MainActor
@Observable
class SpeechService: SpeechServiceProtocol {
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "pt-BR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var lastProcessedString: String = ""

    func startListening(matchManager: MatchManager) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                Task { @MainActor in
                    if !(authStatus == .authorized && granted) {
                        print("Erro: Permissões de voz ou microfone negadas.")
                        return
                    }
                    
                    self.startRecording(matchManager: matchManager)
                }
            }
        }
    }

    private func startRecording(matchManager: MatchManager) {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Erro ao configurar a sessão de áudio: \(error)")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Não foi possível criar o SFSpeechAudioBufferRecognitionRequest")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        lastProcessedString = ""

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let self = self, let result = result else {
                self?.stopListening()
                return
            }
            
            let newText = result.bestTranscription.formattedString.lowercased()
            let newWords = newText.replacingOccurrences(of: self.lastProcessedString, with: "")
            
            if newWords.contains("aumente") || newWords.contains("aumentar") {
                // TODO: Criar ações
                print("Comando de voz: AUMENTE")
            }
            
            self.lastProcessedString = newText
            
            if result.isFinal {
                self.stopListening()
                self.startRecording(matchManager: matchManager)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine não pôde ser iniciado: \(error)")
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Erro ao desativar sessão de áudio: \(error)")
        }
    }
}
