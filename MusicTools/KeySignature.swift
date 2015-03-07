import Foundation
let KEY_MAJOR = 0
let KEY_MINOR = 1

class KeySignature {
    private var sharps : Int = 0
    private var flats : Int = 0
    private var root : String = ""
    private var type : Int = 0
    
    struct keys {
        static var typeProperty: Int = 1001
        static var list : [KeySignature] = KeySignature.makeKeySignatureList()
        static var selectedKey = 0
    }
    
    class func makeKeySignatureList() -> [KeySignature] {
        var keys : [KeySignature] = []
        var sharps = 0
        var flats = 0
        //majors
        keys.append(KeySignature(name: "C", type: KEY_MAJOR, sharps: 0, flats: 0))
        
        keys.append(KeySignature(name: "G", type: KEY_MAJOR, sharps: 1, flats: 0))
        keys.append(KeySignature(name: "F", type: KEY_MAJOR, sharps: 0, flats: 1))
        keys.append(KeySignature(name: "D", type: KEY_MAJOR, sharps: 2, flats: 0))
        keys.append(KeySignature(name: "Bb", type: KEY_MAJOR, sharps: 0, flats: 2))
        
        keys.append(KeySignature(name: "A", type: KEY_MAJOR, sharps: 3, flats: 0))
        keys.append(KeySignature(name: "Eb", type: KEY_MAJOR, sharps: 0, flats: 3))
        keys.append(KeySignature(name: "E", type: KEY_MAJOR, sharps: 4, flats: 0))
        keys.append(KeySignature(name: "Ab", type: KEY_MAJOR, sharps: 0, flats: 4))
        
        keys.append(KeySignature(name: "B", type: KEY_MAJOR, sharps: 5, flats: 0))
        keys.append(KeySignature(name: "Db", type: KEY_MAJOR, sharps: 0, flats: 5))
        keys.append(KeySignature(name: "F#", type: KEY_MAJOR, sharps: 6, flats: 0))
        keys.append(KeySignature(name: "Gb", type: KEY_MAJOR, sharps: 0, flats: 6))
        
        //minors
        keys.append(KeySignature(name: "A", type: KEY_MINOR, sharps: 0, flats: 0))
        keys.append(KeySignature(name: "E", type: KEY_MINOR, sharps: 1, flats: 0))
        keys.append(KeySignature(name: "D", type: KEY_MINOR, sharps: 0, flats: 1))
        return keys
    }
    
    init(name : String, type : Int, sharps : Int, flats : Int) {
        self.root = name
        self.type = type
        self.sharps = sharps
        self.flats = flats
    }
    
    //returns how this note is presented on the staff in this key
    func notePresentation(midiNote : Int) -> NotePresentation {
        let octave : Int  = midiNote / Int(12) - 1  //middle c (=60) is most often notated as C octave 4 (C4)
        let noteNormalized = midiNote % 12 //normalize to C=0 to B=11
        let cMajorPres = Note.cMajorNotePresentation(noteNormalized, useFlat: true)
        var noteName = cMajorPres.name
        var accidental = cMajorPres.accidental
        return NotePresentation(name: noteName, octave: octave, accidental: accidental)
    }
    
    class func getSelectedKey() -> KeySignature {
        return keys.list[keys.selectedKey]
    }
}
