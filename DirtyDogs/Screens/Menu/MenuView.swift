//
//  MenuView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI
import CoreHaptics

struct MenuView: View {
    @State var viewModel: MenuViewModelProtocol
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 64) {
                
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 256, alignment: .init(horizontal: .center, vertical: .center))
                    .frame(maxHeight: 243)
                    .padding(.horizontal, 55)
                    .padding(.top, 40)
                    .fixedSize()
                    .accessibilityIdentifier(MenuIdentifiers.titleImage.rawValue)
                
                VStack (spacing: 32){
                    GameButton (
                        title: "play",
                        disabled: viewModel.isPlayButtonDisabled
                    ){
                        viewModel.playButtonTapped()
                    }
                    .accessibilityIdentifier(MenuIdentifiers.playButton.rawValue)
                    
                    GameButton(title: "tutorial") {
                        viewModel.showTutorial = true
                    }
                    .accessibilityIdentifier(MenuIdentifiers.tutorialButton.rawValue)
                    
                }
                
                HStack (spacing: 55) {
                    ConfigButton(
                        isActive: $viewModel.soundEnabled,
                        images: ["SoundButton", "SoundButtonDisabled"],
                        onTap: {
                            viewModel.toggleSound()
                        }
                    )
                    .accessibilityIdentifier(MenuIdentifiers.soundButton.rawValue)
                    
                    ConfigButton(
                        isActive: $viewModel.hapticsEnabled,
                        images: ["HapticsButton", "HapticsButtonDisabled"],
                        onTap: {
                            viewModel.toggleHaptics()
                        }
                    )
                    .accessibilityIdentifier(MenuIdentifiers.hapticsButton.rawValue)
                }
                
                Spacer()
                
            }
            .background( MovingBackground())
            .padding(.top, 20)
            .navigationDestination(isPresented: $viewModel.showTutorial) {
                TutorialView(viewModel: TutorialViewModel())
            }
            .onAppear{
                AudioService.shared.playLoopSimple(sound: "MenuSound.mp3", volume: 0.1)
            }
            .onDisappear {
                AudioService.shared.stopSimpleLoop(sound: "MenuSound.mp3")
            }
        }
        .accessibilityIdentifier(MenuIdentifiers.menuView.rawValue)
        .statusBarHidden()
    }
}

#Preview {
    MenuView(
        viewModel: MenuViewModel(
            matchManager: MatchManager(),
            hapticsService: HapticsService(),
            settingsService: SettingsService()
        )
    )
}
