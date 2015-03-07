import Foundation

let ACCIDENTAL_NONE = 0
let ACCIDENTAL_SHARP = 1
let ACCIDENTAL_FLAT = 2
let ACCIDENTAL_NATURAL = 3

// describes how the note is presented on a music staff (usually in a given key)
class NotePresentation {
    var name : String
    var octave : Int
    var accidental : Int
    
    init (name: String, octave: Int, accidental : Int) {
        self.name = name
        self.octave = octave
        self.accidental = accidental
    }
    
    func toString() -> String {
        return "note presentation name:\(self.name) octave:\(octave) accidental:\(accidental)"
    }
}

class Note : Duration {
    var noteValue : Int
    
    init(noteValue : Int) {
        self.noteValue = noteValue
        super.init(duration: DURATION_QTR)
    }
    
    init(noteValue : Int, duration : Float) {
        self.noteValue = noteValue
        super.init(duration: duration)
    }
    
    init(note : Note) {
        self.noteValue = note.noteValue
        super.init(duration: note.duration)
    }
    
    class func noteDescription(note : Note, withOctave : Bool) -> String {
        var noteValue = note.noteValue % 12
        var octave = (note.noteValue / 12) - 1 //by convention middle C is octave 4
        var noteName=""
        switch (noteValue) {
        case 0: noteName = "C"
        case 1: noteName = "C#"
        case 2: noteName = "D"
        case 3: noteName = "Eb"
        case 4: noteName = "E"
        case 5: noteName = "F"
        case 6: noteName = "F#"
        case 7: noteName = "G"
        case 8: noteName = "Ab"
        case 9: noteName = "A"
        case 10: noteName = "Bb"
        case 11: noteName = "B"
        default : noteName = ""
        }
        if withOctave {
            return ("\(noteName)(\(octave))")
        }
        else {
            return ("\(noteName)")
        }
    }
    
    //returns how the note would be presented in the C major scale
    class func cMajorNotePresentation(midiNoteValue : Int, useFlat: Bool) -> NotePresentation {
        var noteOffset = midiNoteValue % 12
        let octave = midiNoteValue / Int(12) - 1
        var accidental = ACCIDENTAL_NONE
        
        if !Piano.isWhiteNote(noteOffset) {
            if useFlat {
                accidental = ACCIDENTAL_FLAT
                noteOffset += 1 //e.g. F# becomes Gb
            }
            else {
                accidental = ACCIDENTAL_SHARP
            }
        }
        
        var name = ""
        switch (noteOffset) {
            case 0,1: name = "C"
            case 2,3: name = "D"
            case 4: name = "E"
            case 5,6: name = "F" //e.g. note name for 6 = F# is 'F' (and a # is applied)
            case 7,8: name = "G"
            case 9,10: name = "A"
            case 11: name = "B"
            default: name = ""
        }
        return NotePresentation(name: name, octave: octave, accidental: accidental)
    }
}

