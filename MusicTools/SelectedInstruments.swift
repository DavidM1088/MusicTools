import Foundation

class MidiInstrument {
    var name : String
    var id : Int // midi Identifier
    init (name: String, id: Int) {
        self.name = name
        self.id = id
    }
}

class SelectedInstruments {

    var instruments : [MidiInstrument]
    var selected : Int
    
    init() {
        self.instruments = []
        instruments.append(MidiInstrument(name: "Piano", id: 1))
        instruments.append(MidiInstrument(name: "Glockenspiel", id: 9))
        instruments.append(MidiInstrument(name: "Vibraphone", id: 11))
        instruments.append(MidiInstrument(name: "Marimba", id: 12))
        instruments.append(MidiInstrument(name: "Nylon Guitar", id: 24))
        instruments.append(MidiInstrument(name: "Overdrive Guitar", id: 29))
        instruments.append(MidiInstrument(name: "Electric Guitar", id: 30))
        instruments.append(MidiInstrument(name: "Acoustic Bass", id: 32))
        instruments.append(MidiInstrument(name: "Cello", id:42))
        instruments.append(MidiInstrument(name: "Stereo Strings", id:44))
        instruments.append(MidiInstrument(name: "Synth Strings", id: 50))
        instruments.append(MidiInstrument(name: "Choir", id: 52))
        instruments.append(MidiInstrument(name: "Synth", id: 54))
        instruments.append(MidiInstrument(name: "Trumpet", id: 56))
        instruments.append(MidiInstrument(name: "Tuba", id: 58))
        instruments.append(MidiInstrument(name: "French Horn", id: 60))
        instruments.append(MidiInstrument(name: "Oboe", id: 68))
        instruments.append(MidiInstrument(name: "Clarinet", id: 71))
        instruments.append(MidiInstrument(name: "Flute", id:73))
        instruments.append(MidiInstrument(name: "Fantasia", id:88))
        instruments.append(MidiInstrument(name: "Warm Pad", id:89))
        instruments.append(MidiInstrument(name: "Soundtrack", id:97))
        selected = 8
    }
    
    class var sharedInstance: SelectedInstruments {
        struct Singleton {
            static let instance = SelectedInstruments()
        }
        return Singleton.instance
    }
    
    class func getSelectedInstrument() -> Int {
        return sharedInstance.instruments[sharedInstance.selected].id
    }

}