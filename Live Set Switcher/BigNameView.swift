//
//  BigName.swift
//  Live Set Switcher
//
//  Created by jp on 8/2/22.
//

import SwiftUI

struct BigNameView: View {
    @Binding var showBigName: Bool
    @Binding var name: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(Color(.textBackgroundColor)).opacity(1.0)
            
            VStack {
                
                Text(name)
                    .font(.system(size: 150))
                    .multilineTextAlignment(.center)
                /*
                Divider()
                
                Button(action: {
                    self.showBigName.toggle()
                    for window in NSApplication.shared.windows {
                        window.level = .normal
                    }
                } ) {
                    Text("Close")
                }
                 */
                
            }//vstack

        }//zstack

    }
}
