import Foundation
let KEY_MAJOR = 0
let KEY_MINOR = 1

class KeySignature {
    private var sharps : Int = 0
    private var flats : Int = 0
    private var root : String = ""
    private var type : Int = 0
    private var rootNote : Int = 0
    
    init(root : String, type : Int, sharps : Int, flats : Int, rootNote : Int) {
        self.root = root
        self.type = type
        self.sharps = sharps
        self.flats = flats
        self.rootNote = rootNote
    }
    
    func getName() -> String {
        var typeName = type == KEY_MAJOR ? "Major" : "Minor"
        return "\(self.root) \(typeName)"
    }
    
    func getSharpCount() -> Int {
        return self.sharps
    }
    func getRootNote() -> Int {
        return self.rootNote
    }
    
    //returns how this note is presented on the staff in this key
    func notePresentation(midiNote : Int, sharpMode : Int) -> NotePresentation {
        let octave : Int  = midiNote / Int(12) - 1  //middle c (=60) is most often notated as C octave 4 (C4)
        let noteNormalized = midiNote % 12 //normalize to C=0 to B=11
        //let cMajorPres = Note.cMajorNotePresentation(noteNormalized, useFlat: true)
        let noteOffset = noteNormalized - rootNote
        var noteName = "C"
        var accidental = ACCIDENTAL_NONE // cMajorPres.accidental
        switch (noteNormalized) {
        case 0: noteName = "C"
        case 1: noteName = sharpMode == ACCIDENTAL_SHARP ? "C" : "D"
        case 2: noteName = "D"
        case 3: noteName = sharpMode == ACCIDENTAL_SHARP ? "D" : "E"
        case 4: noteName = "E"
        case 5: noteName = "F"
        case 6: noteName = sharpMode == ACCIDENTAL_SHARP ? "F" : "G"
        case 7: noteName = "G"
        case 8: noteName = sharpMode == ACCIDENTAL_SHARP ? "G" : "A"
        case 9: noteName = "A"
        case 10: noteName = sharpMode == ACCIDENTAL_SHARP ? "A" : "B"
        case 11: noteName = "B"
        default: noteName = ""
        }
        return NotePresentation(name: noteName, octave: octave, accidental: accidental)
    }

    //return the accidental type (sharp, flat) of this key
    func getAccidentalType() -> Int {
        if self.sharps > 0 {return ACCIDENTAL_SHARP} else {return ACCIDENTAL_FLAT}
    }
    
    //return the list of accidentals as midi values
    func getAccidentals(staffType : Int) -> [Int] {
        var list : [Int] = []
        let baseMidi = staffType == CLEF_TREBLE ? MIDDLE_C : MIDDLE_C - 2*12
        
        if self.sharps > 0 {
            for var i=0; i<self.sharps; i++ {
                switch (i) {
                case 0: list.append(baseMidi + 12 + 5)
                case 1: list.append(baseMidi + 12 + 0)
                case 2: list.append(baseMidi + 12 + 7)
                case 3: list.append(baseMidi + 12 + 2)
                case 4: list.append(baseMidi + 0  + 9)
                case 5: list.append(baseMidi + 12 + 4)
                case 6: list.append(baseMidi + 0  + 11)
                default: list.append(0)
                }
            }
        }
        else {
            for var i=0; i<self.flats; i++ {
                switch (i) {
                case 0: list.append(baseMidi +  0 + 11)
                case 1: list.append(baseMidi + 12 + 4)
                case 2: list.append(baseMidi + 0  + 9)
                case 3: list.append(baseMidi + 12 + 2)
                case 4: list.append(baseMidi + 0  + 7)
                case 5: list.append(baseMidi + 12 + 0)
                case 6: list.append(baseMidi + 0  + 5)
                default: list.append(0)
                }
            }
        }
        return list
    }
    
    class func getCommonKeys() -> [KeySignature] {
        var commonKeys : [KeySignature] = []
        commonKeys.append(SelectedKeys.getKeyList()[0])
        commonKeys.append(SelectedKeys.getKeyList()[1])
        commonKeys.append(SelectedKeys.getKeyList()[2])
        commonKeys.append(SelectedKeys.getKeyList()[3])
        commonKeys.append(SelectedKeys.getKeyList()[4])
        commonKeys.append(SelectedKeys.getKeyList()[5])
        commonKeys.append(SelectedKeys.getKeyList()[6])
        commonKeys.append(SelectedKeys.getKeyList()[7])
        commonKeys.append(SelectedKeys.getKeyList()[8])
        commonKeys.append(SelectedKeys.getKeyList()[10])
        return commonKeys
        
    }
}
