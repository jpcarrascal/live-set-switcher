//
//  SetList.swift
//  Live Set Switcher
//
//  Created by jp on 7/27/22.
//

import SwiftUI
import SwiftCSV

struct LiveSet: Identifiable, Codable {
    let id: Int
    var pcNumber: Int32
    var name: String
    var location: String
}

class SetList: ObservableObject {
    
    @Published public var selection : LiveSet.ID? = -1
    
    @Published var liveSets = [LiveSet]()

    @Published var currentLiveSet: LiveSet = LiveSet(id: -1, pcNumber: -1, name: "[No set selected]", location: "")

    init (){
        if let data = UserDefaults.standard.value(forKey:"setList") as? Data {
            liveSets = try! PropertyListDecoder().decode(Array<LiveSet>.self, from: data)
        }
    }
    
    public func loadSetFromPC(pc: Int32) -> String {
        if(pc < 0) {
            return "";
        } else {
            //DispatchQueue.main.async {
            //selectSet(pc: pc)
            print("Coming from MIDIhelper: " + String(pc))
            return "(PC: " + String(pc) + ")";
        }
    }
    
    public func selectSet(pc: Int32, load: Bool) {
        for liveSet in liveSets {
            if(liveSet.pcNumber == pc) {
                currentLiveSet = liveSet
                selection = currentLiveSet.id
                if (load) { loadSet(pc: pc) }
                return
            }
        }
        print("PC not in list: " + String(pc))
    }

    public func loadSet(pc: Int32? = nil) {
        if(currentLiveSet.id >= 0) {
            print("Loading " + currentLiveSet.location)
            let app = "/Applications/Ableton Live 11 Suite.app"
            let file = currentLiveSet.location
            let appUrl = URL(fileURLWithPath: app)
            let url = [URL(fileURLWithPath: file)]
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open(url, withApplicationAt: appUrl, configuration: configuration)
        }
    }
    
    public func loadSetlist() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            let filename = panel.url?.path ?? "<none>"
            do {
                let csvData: CSV = try CSV<Named>(url: URL(fileURLWithPath: filename))
                // TODO:
                // Verify:
                // - At least 2 cols (PC, location)
                // - PC is num [0-127], location is string/path
                // - All rows include necessary columns (PCs, location)
                // [Ignore non-compliant rows]
                // - PCs are not repeated across rows
                liveSets = []
                var index = 0
                csvData.rows.forEach{ elem in
                    if(elem["pc"] != "" && elem["name"] != "" && elem["location"] != "") {
                        let pcn = elem["pc"]!
                        let set = LiveSet(id: index, pcNumber: Int32(pcn) ?? -1, name: elem["name"]!, location: elem["location"]!)
                        liveSets.append(set)
                        index += 1
                    }
                }
                UserDefaults.standard.set(try? PropertyListEncoder().encode(liveSets), forKey:"setList")
                currentLiveSet = LiveSet(id: -1, pcNumber: -1, name: "[No set selected]", location: "")
                selection = -1
                print("Loaded: " + filename)
            } catch let error {
                print(error)
            }
        }
    }
}

