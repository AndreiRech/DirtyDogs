//
//  GameAlert.swift
//  DirtyDogs
//
//  Created by Andrei Rech on 08/12/25.
//

import SwiftUI

struct GameAlert: View {
    @Environment(\.dismiss) var dismiss
    var onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Image(.alertBackground)
                .zIndex(-1)
            
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("LEAVING THE GAME?")
                        .font(.machineGunk(19))
                        .foregroundStyle(.sombraCamarelo)
                    
                    Text("Are you sure that you want to leave?")
                        .font(.machineGunk(14))
                        .foregroundStyle(.sombraCamarelo)
                }
                .offset(x: -10)
                
                HStack(spacing: 21) {
                    Button {
                        dismiss()
                    } label: {
                        Image(.cancelAlertButton)
                    }
                    
                    Button {
                        onConfirm()
                    } label: {
                        Image(.leaveAlertButton)
                    }
                }
            }
        }
    }
}

#Preview {
    GameAlert(onConfirm: {})
}
