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
    
    @Binding var midiInSelectedID: MIDI.IO.UniqueID
    @Binding var midiInSelectedDisplayName: String
    @Binding var bigTitleDisplayed: Bool
    @Binding var midiChannelSelectedID: Int32
    //Binding var currentLiveSet : LiveSet
    
    var body: some View {
        
        VStack {
            /*
            Group {
                Text("Ableton Live set selector")
            }
            .font(.system(size: 14))
            .padding(5)
            */
            GroupBox(label: Text("MIDI Input")) {
                
                Text("Live sets will be selected when receiving Program Change (PC) messages coming from:")
                
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
                LiveSetSelectionView()//currentLiveSet: $currentLiveSet)
            }
            .padding(5)
            
            GroupBox(label: Text("Received Events")) {
                List(midiHelper.receivedEvents.reversed(), id: \.self) {
                    Text($0.description)
                        .foregroundColor(color(for: $0))
                }
            }
            
        }
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
    
}

