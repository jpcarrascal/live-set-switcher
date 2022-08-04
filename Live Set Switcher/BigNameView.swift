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
                //.frame(width: 800, height: 300, alignment: .center)
                .foregroundColor(Color(.textBackgroundColor)).opacity(1.0)
            VStack {
                Text(name)
                    .font(.system(size: 100))
                    .multilineTextAlignment(.center)
                //Divider()
                Button(action: {
                    self.showBigName.toggle()
                    for window in NSApplication.shared.windows {
                        window.level = .normal
                    }
                } ) {
                    Text("Close")
                        //.foregroundColor(.blue)
                        //.font(.system(size: 20))
                }
            }//vstack
            //.frame(width: 780, height: 150, alignment: .center)
        }//zstack
    }
}
