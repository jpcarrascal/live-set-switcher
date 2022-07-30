//
//  SetList.swift
//  Live Set Switcher
//
//  Created by jp on 7/27/22.
//

import Foundation
import SwiftUI

struct LiveSet: Identifiable {
    let id: Int
    var pcNumber: Int32
    var name: String
    var location: String
}

class SetList: ObservableObject {
    
    //@Published var selection : LiveSet.ID?
    @State var selection : LiveSet.ID? = -1
    
    public private(set) var liveSets = [
        LiveSet(id: 0, pcNumber: 0, name: "Track 0", location: "/Users/jp/Desktop/00 Project/00.als"),
        LiveSet(id: 1, pcNumber: 1, name: "Track 1", location: "/Users/jp/Desktop/01 Project/01.als"),
        LiveSet(id: 2, pcNumber: 2, name: "Track 2", location: "/Users/jp/Desktop/02 Project/02.als"),
        LiveSet(id: 3, pcNumber: 3, name: "Track 3", location: "/Users/jp/Desktop/03 Project/03.als")
    ]
    
    @Published var currentLiveSet: LiveSet = LiveSet(id: -1, pcNumber: -1, name: "", location: "")

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
    
    public func selectSet(pc: Int32, send: Bool) {
        for liveSet in liveSets {
            if(liveSet.pcNumber == pc) {
                currentLiveSet = liveSet
                selection = currentLiveSet.id
                print("Selecting " + String(pc))
                if (send) { loadSet(pc: pc) }
                return
            }
        }
        print("PC not in list: " + String(pc))
    }

    public func loadSet(pc: Int32? = nil) {
        //if(pc != nil) {
        //    selectSet(pc: pc!)
        //}
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
}
