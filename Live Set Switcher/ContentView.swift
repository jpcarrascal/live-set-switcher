//
//  ContentView.swift
//  EndpointPickers
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import SwiftUI
import MIDIKit

struct ContentView: View {
    
    @EnvironmentObject var midiManager: MIDI.IO.Manager
    @EnvironmentObject var midiHelper: MIDIHelper
    @EnvironmentObject var setList: SetList
    
    @Binding var midiInSelectedID: MIDI.IO.UniqueID
    @Binding var midiInSelectedDisplayName: String
    @Binding var midiChannelSelectedID: Int32
    
    @State var showBigName = false
    
    var body: some View {
        ZStack{
            
            VStack {

                GroupBox(label: Text("MIDI Input")) {
                    
                    MIDIInSelectionView(
                        midiInSelectedID: $midiInSelectedID,
                        midiInSelectedDisplayName: $midiInSelectedDisplayName
                    )
                    .padding([.leading, .trailing], 60)
                    
                    MIDIChannelSelectionView(
                        midiChannelSelectedID: $midiChannelSelectedID
                    )
                    .padding([.leading, .trailing], 60)
                }
                .padding(5)
                
                GroupBox(label: Text("Live Set")) {
                    SetSelectView()
                }
                .padding(5)
                /*
                GroupBox(label: Text("Received Events")) {
                    List(midiHelper.receivedEvents.reversed(), id: \.self) {
                        Text($0.description)
                            .foregroundColor(color(for: $0))
                    }
                }
                 */
                
            } // Vstack
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            //.padding()
            
            if self.showBigName {
                BigNameView(showBigName: self.$showBigName, name: $setList.currentLiveSet.name)
            }
            
        } // ZStack
        
        HStack {
            
            Button("Open with Live") {
                setList.loadSet()
            }.disabled(setList.currentLiveSet.id < 0)
            
            Button(action: {
                self.showBigName.toggle()
                switchLevel(state: self.showBigName)
            }) {
                if(self.showBigName) {
                    Text("Hide Big Name")
                } else {
                    Text("Show Big Name")
                }
                
            }
            
        } //Hstack
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .padding()
    }
        
    func color(for event: MIDI.Event) -> Color? {
        switch event {
        case .noteOn: return .green
        case .noteOff: return .red
        case .cc: return .orange
        case .programChange: return .blue
        default: return nil
        }
    }
    
    func switchLevel(state: Bool) {
        if(state) {
            for window in NSApplication.shared.windows {
                window.level = .floating
            }
        } else {
            for window in NSApplication.shared.windows {
                window.level = .normal
            }
        }

    }
    
} 
