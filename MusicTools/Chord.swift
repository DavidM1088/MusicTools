import Foundation

let CHORD_MAJOR=0
let CHORD_MINOR=1
let CHORD_DIMINISHED=2

let DURATION_QTR : Float = 0.25
let NOTE_WHOLE : Float = 1.0

//any object that can be placed on a staff
class StaffObject {
    
}

//an object that has some duration on a staff
class Duration : StaffObject {
    var duration : Float
    init (duration : Float) {
        self.duration = duration
    }
}

class Rest : Duration {
    init() {
        super.init(duration: 0.0)
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
    
    class func noteName(note : Note) -> String {
        var noteValue = note.noteValue % 12
        var octave = note.noteValue / 12
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
        return ("\(noteName)(\(octave))")
    }
}

class Chord  : StaffObject {
    var notes : [Note] = []
    
    init(noteValues : [Int]) {
        for var i=0; i<noteValues.count; i++ {
            self.notes.append(Note(noteValue: noteValues[i]))
        }
    }
    
    init(root:Int, type:Int) {
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
    }
    
    init(chord : Chord) {
        var newNotes : [Note] = []
        for note in chord.notes {
            newNotes.append(Note(note: note))
        }
    }
    
    //use voice leading to move from chord1 to chord 2
    class func voiceLead(chord1 : Chord, chord2 : Chord) -> Chord {
        var candidates :[Chord] = []
        var candidateDiffs :[Int] = []
        var ctr = 0
        // generate all chord transposes near the first chord
        var candidate : Chord = Chord.incrementChord(chord2, incr: -12)
        while ctr < 2 * chord1.notes.count {
            candidates.append(candidate)
            candidateDiffs.append(Chord.chordDifference(candidate, chord2: chord1))
            //println("cand \(candidate.toString()) diff: \(candidateDiffs[ctr])")
            candidate = Chord.transpose(candidate)
            ctr++
        }
        //return the transpose with the lowest score (i.e. closest to first chord)
        var lowestDiff = 9999
        var lowest = 0
        let hiLo: Int = Int(rand()) % 2
        //if 2 candidates have the same score randomize the up or down direction (otherewise a progession just keeps going down..)
        for (var i=0; i<candidates.count; i++) {
            if  (hiLo == 0 && candidateDiffs[i] < lowestDiff) || (hiLo == 1 && candidateDiffs[i] <= lowestDiff) {
                lowestDiff = candidateDiffs[i]
                lowest = i
            }
        }
        return candidates[lowest]
    }
    
    //return a chord adjusted up or down from the given chord by an increment
    class func incrementChord(chord : Chord, incr : Int) -> Chord {
        var noteValues : [Int] = []
        for note in chord.notes {
            noteValues.append(note.noteValue + incr)
        }
        return Chord(noteValues: noteValues)
    }
    
    class func transpose(chord : Chord) -> Chord {
        var noteValues : [Int] = []
        for (var i = 1; i < chord.notes.count; i++) {
            noteValues.append(chord.notes[i].noteValue)
            //newChord.durations[i-1] = chord.durations[i]
        }
        noteValues.append(chord.notes[0].noteValue + 12)
        //newChord.durations[chord.notes.count - 1] = chord.durations[0] + 12
        return Chord(noteValues: noteValues)
    }
    
    class func chordDifference(chord1 : Chord, chord2 : Chord) -> Int {
        var sum = 0
        for (var i=0; i<chord1.notes.count; i++) {
            sum = abs(chord1.notes[i].noteValue - chord2.notes[i].noteValue)
        }
        return sum
    }
    
    func toString() -> String {
        var res : String = "chord:"
        for note in self.notes {
            res = res + "  \(Note.noteName(note)) \(note.noteValue), "
        }
        return res
    }
    
    class func unitTest() {
        var c1 = Chord(noteValues : [60, 64, 67]) // C E G
        var c2 = Chord.transpose(c1)
        //println("\(c1.toString()) transposed to \(c2.toString())")
        
        var c3 = Chord(noteValues : [65, 69, 72]) // F Major
        println("VL ----> \(c1.toString()) to \(c3.toString()) ")
        var c4 = Chord.voiceLead(c1, chord2: c3)
        println("result ----> \(c4.toString())")
        
    }
    
    /*
    // write a sequence of bass note, chord, bass note, chord
    func alternateBass() -> [Sound] {
        var sounds : [Sound] = [Sound]()
        var bassNote : Note = Note(note: notes[0] - 12, duration: durations[0])
        sounds.append(bassNote)
        let chord : Chord = Chord(n: self.notes)
        sounds.append(chord)
        
        bassNote = Note(note: notes[0] - 12 + 7, duration: durations[0])
        sounds.append(bassNote)
        sounds.append(chord)
        return sounds
    }
    
    func waltzBass() -> [Sound] {
        var sounds : [Sound] = [Sound]()
        var bassNote : Note = Note(note: self.notes[0] - 12, duration: durations[0])
        sounds.append(bassNote)
        let chord : Chord = Chord(n: self.notes)
        sounds.append(chord)
        sounds.append(chord)
        return sounds
    }
    
    func albertiBass() -> [Sound] {
        var sounds : [Sound] = [Sound]()
        var bassNote : Note = Note(note: notes[0], duration: durations[0])
        var topNote : Note = Note(note: notes[2], duration: durations[0])
        var middleNote : Note = Note(note: notes[1], duration: durations[0])
        sounds.append(bassNote)
        sounds.append(topNote)
        sounds.append(middleNote)
        sounds.append(topNote)
        return sounds
    }
    
    func blockBass() -> [Sound] {
        var sounds : [Sound] = [Sound]()
        var bassNote : Note = Note(note: notes[0], duration: durations[0])
        var topNote : Note = Note(note: notes[2], duration: durations[0])
        var middleNote : Note = Note(note: notes[1], duration: durations[0])
        sounds.append(self)
        return sounds
    }

    
*/
}

    