//
//  GameAlert.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 08/12/25.
//

import SwiftUI

struct GameAlert: View {
    var onCancel: () -> Void
    var onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Image(.alertBackground)
                .zIndex(-1)
            
            VStack(spacing: 14) {
                VStack(alignment: .center, spacing: 0) {
                    Text("LEAVE THE MATCH?")
                        .font(.machineGunk(32))
                        .foregroundStyle(.sombraCamarelo)
                    
                    Text("Are you sure you want to exit?")
                        .font(.machineGunk(16))
                        .foregroundStyle(.sombraCamarelo)
                }
                
                HStack(spacing: 32) {
                    Button {
                        onCancel()
                    } label: {
                        Image(.leaveAlertButton)
                    }
                    
                    Button {
                        onConfirm()
                    } label: {
                        Image(.cancelAlertButton)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    GameAlert(onCancel: {}, onConfirm: {})
}
