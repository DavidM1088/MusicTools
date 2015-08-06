import Foundation

let CHORD_MAJOR=0
let CHORD_MINOR=1
let CHORD_DIMINISHED=2

let DURATION_QTR : Float = 0.25
let NOTE_WHOLE : Float = 1.0

class Chord  : StaffObject {
    var notes : [Note] = []
    
    func sortNotes() {
        //ensure the notes are ordered lowest to highest
        let sortedNotes = sorted(notes, { (s1: Note, s2: Note) -> Bool in
            return s1.noteValue < s2.noteValue
        })
        self.notes = []
        for var i=0; i<sortedNotes.count; i++ {
            self.notes.append(sortedNotes[i])
        }
    }
    
    init(noteValues : [Int]) {
        super.init()
        for var i=0; i<noteValues.count; i++ {
            self.notes.append(Note(noteValue: noteValues[i]))
        }
        sortNotes()
    }
    
    init(root:Int, type:Int) {
        super.init()
        var noteValues : [Int] = []
        if type == CHORD_MAJOR {
            noteValues = [root, root+4, root+7]
        }
        if type == CHORD_MINOR {
            noteValues = [root, root+3, root+7]
        }
        if type == CHORD_DIMINISHED {
            noteValues = [root, root+3, root+6]
        }
        for noteValue in noteValues {
            notes.append(Note(noteValue : noteValue))
        }
        sortNotes()
    }
    
    init(chord : Chord) {
        super.init()
        notes = []
        for note in chord.notes {
            notes.append(Note(note: note))
        }
        sortNotes()
    }
    
    //return the best inversion of chord 2 using voice leading to move from chord1 to chord 2
    class func voiceLead(chord1 : Chord, chord2 : Chord) -> Chord {
        println("voice_lead \(chord1.toString()) to: \(chord2.toString())")
        var candidates :[Chord] = []
        var candidateDiffs :[Int] = []
        var ctr = 0
        // generate all chord transposes near the first chord
        var candidate : Chord = Chord.incrementChord(chord2, incr: -24)
        while ctr < 4 * chord1.notes.count {
            candidates.append(candidate)
            candidateDiffs.append(Chord.chordDifference(candidate, chord2: chord1))
            println("cand \(candidate.toString()) diff: \(candidateDiffs[ctr])")
            candidate = Chord.invert(candidate)
            ctr++
        }
        //return the transpose with the lowest score (i.e. closest to first chord)
        var lowestDiff = 9999
        var lowest = 0
        let hiLo: Int = Int(rand()) % 2
        //if 2 candidates have the same score randomize the up or down direction (otherwise a progession just keeps going down..)
        for (var i=0; i<candidates.count; i++) {
            if  (hiLo == 0 && candidateDiffs[i] < lowestDiff) || (hiLo == 1 && candidateDiffs[i] <= lowestDiff) {
                lowestDiff = candidateDiffs[i]
                lowest = i
            }
        }
        return candidates[lowest]
    }
    
    //make a random bigger size chord using just the notes of the input chord
    class func expandChord(chordIn : Chord, chordSize : Int, lo: Int, hi : Int) -> Chord {
        let baseNotes = chordIn.notes
        var notes = [Int]()
        var count = 0
        
        while notes.count < chordSize {
            count = count + 1
            if (count > 500) {
                break; //avoid can't meet conditions
            }
            let octave = Int(rand()) % 2
            let noteIndex = Int(rand()) % baseNotes.count
            let noteValue = baseNotes[noteIndex].noteValue - (octave * 12)
            if (noteValue < lo || noteValue > hi) {
                continue
            }
            if (contains(notes, noteValue)) {
                continue
            }
            notes.append(noteValue)
        }
        var chord = Chord(noteValues: notes)
        return chord
    }
    
    //return a chord adjusted up or down from the given chord by an increment
    class func incrementChord(chord : Chord, incr : Int) -> Chord {
        var noteValues : [Int] = []
        for note in chord.notes {
            noteValues.append(note.noteValue + incr)
        }
        return Chord(noteValues: noteValues)
    }
    
    class func invert(chord : Chord) -> Chord {
        var noteValues : [Int] = []
        for (var i = 1; i < chord.notes.count; i++) {
            noteValues.append(chord.notes[i].noteValue)
            //newChord.durations[i-1] = chord.durations[i]
        }
        noteValues.append(chord.notes[0].noteValue + 12)
        //newChord.durations[chord.notes.count - 1] = chord.durations[0] + 12
        return Chord(noteValues: noteValues)
    }
    
    class func removeNote(chord : Chord, noteNum : Int) -> Chord {
        var noteValues : [Int] = []
        for (var i = 0; i < chord.notes.count; i++) {
            if (i != noteNum) {
                noteValues.append(chord.notes[i].noteValue)
            }
        }
        return Chord(noteValues: noteValues)
    }
    
    class func chordDifference(chord1 : Chord, chord2 : Chord) -> Int {
        var sum = 0
        for (var i=0; i<chord1.notes.count; i++) {
            sum = abs(chord1.notes[i].noteValue - chord2.notes[i].noteValue)
        }
        return sum
    }
    
    class func romanNumeralNotation(note : Int) -> String {
        switch (note) {
        case 0 : return "I Tonic"
        case 2 : return "ii Minor"
        case 4 : return "iii Minor"
        case 5 : return "IV Subdominant"
        case 7 : return "V Dominant"
        case 9 : return "vi Minor"
        case 11 : return "vii Diminished"
        default : return "unknown"
        }
    }
    
    func toString() -> String {
        var res : String = "chord:"
        for note in self.notes {
            res = res + "  \(Note.noteDescription(note, withOctave: true)) \(note.noteValue), "
        }
        return res
    }
    
    class func unitTest() {
        var c1 = Chord(noteValues : [60, 64, 67]) // C E G
        var c2 = Chord.invert(c1)
        //println("\(c1.toString()) transposed to \(c2.toString())")
        
        var c3 = Chord(noteValues : [65, 69, 72]) // F Major
        println("VL ----> \(c1.toString()) to \(c3.toString()) ")
        var c4 = Chord.voiceLead(c1, chord2: c3)
        println("result ----> \(c4.toString())")
        
    }
    
}

    