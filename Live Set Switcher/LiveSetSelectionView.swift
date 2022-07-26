//
//  MIDIEndpointSelectionView.swift
//  EndpointPickers
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import SwiftUI
import MIDIKit
/*
struct SongListView: View {
    
 
    
}
*/

struct LiveSet: Identifiable {
    let id: Int
    var pcNumber: Int
    var name: String
    var location: String
}

struct LiveSetSelectionView: View {
    @State private var liveSets = [
        LiveSet(id: 0, pcNumber: 0, name: "Track 0", location: "/Users/jp/Desktop/00 Project/00.als"),
        LiveSet(id: 1, pcNumber: 1, name: "Track 1", location: "/Users/jp/Desktop/01 Project/01.als"),
        LiveSet(id: 2, pcNumber: 2, name: "Track 2", location: "/Users/jp/Desktop/02 Project/02.als"),
        LiveSet(id: 3, pcNumber: 3, name: "Track 3", location: "/Users/jp/Desktop/03 Project/03.als")
    ]
    @State var selection : LiveSet.ID?
    @State private var showRow = false
    
    @State var currentLiveSet: LiveSet = LiveSet(id: -1, pcNumber: -1, name: "", location: "")
    //@Binding var currentLiveSet: LiveSet

    var body: some View {
        Table(liveSets, selection: $selection) {
            TableColumn("PCnum") { liveSet in
                Text(String(liveSet.pcNumber))
            }
            TableColumn("Name") { liveSet in
                //TextEditor(text: $liveSets[liveSet.id-1].name)
                Text(String(liveSet.name))
                /*
                    .onTapGesture(count: 2, perform: {
                        print(liveSet.name + " selected")
                        currentLiveSet = LiveSet(id: liveSet.id,
                                                 pcNumber: liveSet.pcNumber,
                                                 name: liveSet.name,
                                                 location: liveSet.location)
                    })
                 */
            }
            TableColumn("Location", value: \.location)
        }.onChange(of: selection) { value in
            currentLiveSet = liveSets[selection!]
        }
        Text(setText(theText: currentLiveSet.name))
        
        Button("Load Live Set") {
            loadSet()
        }
        
        Button("test") {
            selectSet(pc: 2)
        }

    }
    
    public func selectSet(pc: Int32) {
        for liveSet in liveSets {
            if(liveSet.pcNumber == pc) {
                self.selection = liveSet.id
            }
        }
    }
    
    public func loadSet() {
        if(currentLiveSet.id >= 0) {
            let app = "/Applications/Ableton Live 11 Suite.app"
            let file = currentLiveSet.location
            let appUrl = URL(fileURLWithPath: app)
            let url = [URL(fileURLWithPath: file)]
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open(url, withApplicationAt: appUrl, configuration: configuration)
        }
    }
    
    func setText(theText: String) -> String {
        if(theText == "") {
            return "No set selected";
        } else {
            return "Selected: " + theText;
        }
    }
}


