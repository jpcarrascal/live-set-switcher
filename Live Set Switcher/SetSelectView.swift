//
//

import SwiftUI

struct SetSelectView: View {
    
    
    @EnvironmentObject var midiHelper: MIDIHelper
    //@StateObject var setList = SetList()
    @EnvironmentObject var setList: SetList
    
    //@State private var selection : LiveSet.ID?

    var body: some View {
        Table(setList.liveSets, selection: $setList.selection) {
            TableColumn("PCnum") { liveSet in
                Text(String(liveSet.pcNumber))
            }.width(ideal: 1)
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
        }.onChange(of: setList.selection) { value in
            print("CHanging list selection: " + String(setList.liveSets[setList.selection!].pcNumber))
            setList.selectSet(pc: setList.liveSets[setList.selection!].pcNumber, send: false)
        }
        HStack {
            Text(setText(theText: setList.currentLiveSet.name))
            Text(String(midiHelper.receivedPC))
            Text(">>>" + String(setList.selection!))
        }
        
        Button("Load Live Set") {
            setList.loadSet()
        }
        
        Button("test") {
            setList.selectSet(pc: 2, send: true)
        }

    }
    
    private func setText(theText: String) -> String {
        if(theText == "") {
            return "No set selected";
        } else {
            return "Selected: " + theText;
        }
    }
}


