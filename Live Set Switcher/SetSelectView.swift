//
//

import SwiftUI
import SwiftCSV

struct SetSelectView: View {
    
    
    @EnvironmentObject var midiHelper: MIDIHelper
    //@StateObject var setList = SetList()
    @EnvironmentObject var setList: SetList
    
    @State private var selection : LiveSet.ID?
    
    @State var filename = ""

    var body: some View {
        
        HStack {
          Text(filename)
          Button("Load Set List...")
          {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            if panel.runModal() == .OK {
                filename = panel.url?.path ?? "<none>"
                do {
                    let csvData: CSV = try CSV<Named>(url: URL(fileURLWithPath: filename))
                    setList.liveSets = []
                    var index = 0
                    csvData.rows.forEach{ elem in
                        var pcn = elem["pc"]!
                        var set = LiveSet(id: index, pcNumber: Int32(pcn) ?? -1, name: elem["name"]!, location: elem["location"]!)
                        setList.liveSets.append(set)
                        index += 1
                    }
                } catch let error {
                    print(error)
                }
            }
          }
        }
        
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


