//
//

import SwiftUI

struct SetSelectView: View {
    
    @EnvironmentObject var midiHelper: MIDIHelper
    @EnvironmentObject var setList: SetList
    
    @State private var selection : LiveSet.ID?

    var body: some View {
        ZStack {
            VStack {
                
                Table(setList.liveSets, selection: $setList.selection) {
                    TableColumn("PCnum") { liveSet in
                        Text(String(liveSet.pcNumber))
                    }.width(ideal: 1)
                    TableColumn("Name") { liveSet in
                        Text(String(liveSet.name))
                    }
                    TableColumn("Location", value: \.location)
                }.onChange(of: setList.selection) { value in
                    let index = setList.selection ?? -1
                    if(index >= 0) {
                        setList.selectSet(pc: setList.liveSets[index].pcNumber, load: false)
                    }
                }

                VStack {
                    Text("Selected set:")
                    
                    Text(setList.currentLiveSet.name).font(.system(size: 25)).opacity(setOpacity(theText: setList.currentLiveSet.name))
                }

            }
        
        }.onChange(of: midiHelper.receivedPC){ value in
            setList.selectSet(pc: midiHelper.receivedPC, load: true)
        }

    }
    
    private func setOpacity(theText: String) -> Double {
        if(theText == "[No set selected]") {
            return 0.5;
        } else {
            return 1.0;
        }
    }
    
}
