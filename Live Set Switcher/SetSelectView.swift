//
//

import SwiftUI
import SwiftCSV

struct SetSelectView: View {
    
    @EnvironmentObject var midiHelper: MIDIHelper
    //@StateObject var setList = SetList()
    @EnvironmentObject var setList: SetList
    
    @State private var selection : LiveSet.ID?
    
    @State var filename = " "
    
    @State var showBigName = false

    var body: some View {
        ZStack {
            VStack {
                HStack {
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
                            var pcn = ""
                            csvData.rows.forEach{ elem in
                                pcn = elem["pc"]!
                                var set = LiveSet(id: index, pcNumber: Int32(pcn) ?? -1, name: elem["name"]!, location: elem["location"]!)
                                setList.liveSets.append(set)
                                index += 1
                            }
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(setList.liveSets), forKey:"setList")
                        } catch let error {
                            print(error)
                        }
                    }
                  }
                    Text(filename)
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
                    let index = setList.selection ?? -1
                    if(index >= 0) {
                        print("Changing list selection: " + String(setList.liveSets[index].pcNumber))
                        setList.selectSet(pc: setList.liveSets[index].pcNumber, send: false)
                        print("--->" + String(setList.liveSets[index].name))
                    }
                }
                HStack {
                    Text(setText(theText: setList.currentLiveSet.name))
                    Text(String(midiHelper.receivedPC))
        //            Text(">>>" + String(setList.selection!))
                }
                
                Button(action: {
                    if(setList.currentLiveSet.id >= 0) {
                        self.showBigName.toggle()
                    }
                }) {
                    Text("Big Name")
                }
                
                Button("Load Live Set") {
                    setList.loadSet()
                }
                
                Button("test") {
                    setList.selectSet(pc: 2, send: true)
                }
            }
        
            if self.showBigName {
                BigNameView(showBigName: self.$showBigName, name: $setList.currentLiveSet.name)
            }
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
