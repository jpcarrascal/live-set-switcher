//  Borrowed from:
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import SwiftUI
import MIDIKit

class MIDIHelper: ObservableObject {
    
    public weak var midiManager: MIDI.IO.Manager?
    private var channel: Int32
    
    @Published
    public private(set) var receivedEvents: [MIDI.Event] = []
    
    public init(channel: Int32) {
        self.channel = channel
    }
    
    /// Run once after setting the local `midiManager` property.
    public func initialSetup() {
        guard let midiManager = midiManager else {
            print("MIDI Manager is missing.")
            return
        }
        
        do {
            print("Starting MIDI services.")
            try midiManager.start()
        } catch {
            print("Error starting MIDI services:", error.localizedDescription)
        }
        
        do {
            try midiManager.addInputConnection(
                toOutputs: [],
                tag: ConnectionTags.midiIn,
                receiveHandler: .events() { [weak self] events in
                    DispatchQueue.main.async {
                        //self?.receivedEvents.append(contentsOf: events)
                        events.forEach { self?.handleMIDI(event: $0) }
                    }
                }
            )
            
        } catch {
            print("Error creating MIDI connections:", error.localizedDescription)
        }
    }
    
    // MARK: - MIDI In
    
    public var midiInputConnection: MIDI.IO.InputConnection? {
        midiManager?.managedInputConnections[ConnectionTags.midiIn]
    }
    
    public func midiInUpdateConnection(selectedUniqueID: MIDI.IO.UniqueID) {
        guard let midiInputConnection = midiInputConnection else { return }
        
        if selectedUniqueID == 0 {
            midiInputConnection.removeAllOutputs()
        } else {
            if midiInputConnection.outputsCriteria != [.uniqueID(selectedUniqueID)] {
                midiInputConnection.removeAllOutputs()
                midiInputConnection.add(outputs: [.uniqueID(selectedUniqueID)])
            }
        }
    }
    
    
    // MARK: - Helpers
    
    public func isInputPresentInSystem(uniqueID: MIDI.IO.UniqueID) -> Bool {
        midiManager?.endpoints.inputs.contains(whereUniqueID: uniqueID) ?? false
    }
    
    public func isOutputPresentInSystem(uniqueID: MIDI.IO.UniqueID) -> Bool {
        midiManager?.endpoints.outputs.contains(whereUniqueID: uniqueID) ?? false
    }
    
    public func setMIDIChannel(ch: Int32) {
        print("Channel set to: ", ch)
        self.channel = ch;
    }
    
    // MARK: - MIDI handler
    private func handleMIDI(event: MIDI.Event) {
        switch event {
        case .programChange(let payload):
            if(payload.channel.intValue == self.channel) {
                /*print("Program Change:",
                      "\n  Program:", payload.program.intValue,
                      "\n  Bank Select:", payload.bank,
                      "\n  Channel:", payload.channel.intValue,
                      "\n  UMP Group (MIDI2):", payload.group.intValue)
                 */
                if(payload.program.intValue == 1) {
                    //LiveSetSelectionView.selectSet(payload.program.intValue)
                    print("OPENING...")
                    
                }
                self.receivedEvents.append(event)
            } else {
                print("PC coming from different channel: ", payload.channel.intValue)
            }

        default:
            print("NON-PC message")
        }
    }
}
