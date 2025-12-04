//
//  GameOverView.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 12/11/25.
//

import SwiftUI

struct GameOverView: View {
    @State var viewModel: GameOverViewModelProtocol
    
    var body: some View {
        ZStack {
            MovingBackground()
            
            VStack(spacing: 48) {
                
                Image(viewModel.screenTextLines)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 287, alignment: .init(horizontal: .center, vertical: .center))
                    .frame(maxHeight: 348)
                    .padding(.horizontal, 55)
                    .fixedSize()
                
                if let boneImage = viewModel.boneImage {
                    Image(boneImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))
                        .frame(maxHeight: 180)
                        .padding()
                }
                
                
                
                GameButton (
                    title: "return to menu",
                    size: .large
                ){
                    viewModel.returnToMenu()
                }
                .padding()
                .previewLayout(.sizeThatFits)
                
                Spacer()
                
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    GameOverView(viewModel: GameOverViewModel(matchManager: MatchManager()))
}
