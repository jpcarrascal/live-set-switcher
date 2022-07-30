//
//  Live_Set_SwitcherApp.swift
//  Live Set Switcher
//
//  Created by jp on 7/23/22.
//

import SwiftUI
import MIDIKit

@main
struct EndpointPickersApp: App {
    
    let midiManager = MIDI.IO.Manager(
        clientName: "Spacebarman",
        model: "LiveSetSwitcher",
        manufacturer: "JP"
    )
    
    @ObservedObject var midiHelper = MIDIHelper(channel: 0)
    @ObservedObject var setList = SetList()
    
    @State var midiInSelectedID: MIDI.IO.UniqueID = 0
    @State var midiInSelectedDisplayName: String = "None"
    @State var bigTitleDisplayed: Bool = false
    
    @State var midiChannelSelectedID: Int32 = 0
    
    init() {
        midiHelper.midiManager = midiManager
        midiHelper.initialSetup()
        
        // restore saved MIDI endpoint selections and connections
        midiRestorePersistentState()
        midiHelper.midiInUpdateConnection(selectedUniqueID: midiInSelectedID)
        midiHelper.setMIDIChannel(ch: midiChannelSelectedID)
    }
    
    var body: some Scene {
        
        WindowGroup {
            ContentView(
                midiInSelectedID: $midiInSelectedID,
                midiInSelectedDisplayName: $midiInSelectedDisplayName,
                bigTitleDisplayed: $bigTitleDisplayed,
                midiChannelSelectedID: $midiChannelSelectedID
            )
            .environmentObject(midiManager)
            .environmentObject(midiHelper)
            .environmentObject(setList)
            .frame(minWidth: 400, minHeight: 600, alignment: .center)
        }
        
        .onChange(of: midiInSelectedID) {
            if $0 == 0 {
                midiInSelectedDisplayName = "None"
            } else if let found = midiManager.endpoints.outputs
                .first(whereUniqueID: .init($0))
            {
                midiInSelectedDisplayName = found.displayName
            }
            midiHelper.midiInUpdateConnection(selectedUniqueID: $0)
            midiSavePersistentState()
        }
        
        .onChange(of: midiChannelSelectedID) {
            midiChannelSelectedID = $0
            midiHelper.setMIDIChannel(ch: $0)
            midiSavePersistentState()
        }
        
    }
    
}

enum ConnectionTags {
    static let midiIn = "SelectedInputConnection"
}

enum UserDefaultsKeys {
    static let midiInID = "SelectedMIDIInID"
    static let midiInDisplayName = "SelectedMIDIInDisplayName"
    
    static let midiChannelID = "SelectedMIDIChannelID"
}

extension EndpointPickersApp {
    
    /// This should only be run once at app startup.
    private mutating func midiRestorePersistentState() {
        
        print("Restoring saved MIDI connections.")
        
        let inName = UserDefaults.standard.string(forKey: UserDefaultsKeys.midiInDisplayName) ?? ""
        _midiInSelectedDisplayName = State(wrappedValue: inName)
        
        let inID = Int32(exactly: UserDefaults.standard.integer(forKey: UserDefaultsKeys.midiInID)) ?? 0
        _midiInSelectedID = State(wrappedValue: inID)
                
        let channelID = Int32(exactly: UserDefaults.standard.integer(forKey: UserDefaultsKeys.midiChannelID)) ?? 0
        _midiChannelSelectedID = State(wrappedValue: channelID)
        
    }
    
    public func midiSavePersistentState() {
        // save endpoint selection to UserDefaults
        
        UserDefaults.standard.set(midiInSelectedID,
                                  forKey: UserDefaultsKeys.midiInID)
        UserDefaults.standard.set(midiInSelectedDisplayName,
                                  forKey: UserDefaultsKeys.midiInDisplayName)
        
        UserDefaults.standard.set(midiChannelSelectedID,
                                  forKey: UserDefaultsKeys.midiChannelID)
    }
    
}
