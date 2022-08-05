//
//  MIDIEndpointSelectionView.swift
//  EndpointPickers
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import SwiftUI
import MIDIKit

struct MIDIInSelectionView: View {
    
    @EnvironmentObject var midiManager: MIDI.IO.Manager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiInSelectedID: MIDI.IO.UniqueID
    @Binding var midiInSelectedDisplayName: String
    
    var body: some View {
        
        Picker("Input port", selection: $midiInSelectedID) {
            Text("None")
                .tag(0 as MIDI.IO.UniqueID)
            
            if midiInSelectedID != 0,
               !midiHelper.isOutputPresentInSystem(uniqueID: midiInSelectedID)
            {
                Text("⚠️ " + midiInSelectedDisplayName)
                    .tag(midiInSelectedID)
                    .foregroundColor(.secondary)
            }
            
            ForEach(midiManager.endpoints.outputs) {
                Text($0.displayName)
                    .tag($0.uniqueID)
            }
        }
        
    }
    
}

struct MIDIChannelSelectionView: View {
    
    @EnvironmentObject var midiManager: MIDI.IO.Manager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiChannelSelectedID: Int32
    
    var body: some View {
        
        Picker("Channel", selection: $midiChannelSelectedID) {
                Text("[Any]").tag(Int32(-1))
            ForEach((0...15), id: \.self) {
                Text("\($0+1)").tag(Int32($0))
            }
        }
        
    }
    
}



