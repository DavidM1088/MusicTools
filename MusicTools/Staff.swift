import AVFoundation
import UIKit

//the clef notes from a voice are added to
let CLEF_AUTO = 0 //the notes in the voice will be shown in the clef that best fits
let CLEF_TREBLE = 1 // the notes will be shown in the treble clef
let CLEF_BASS = 2

//a voice represents all the notes for an instrument
class Voice {
    var contents = [StaffObject]()
    var instrument : Instrument
    var clef : Int
    var beatNum = 0
    var lastSound : StaffObject?
    
    init(instr: Instrument, clef: Int) {
        instrument = instr
        self.clef = clef
    }
    
    //set the optimal clef to render the notes in this voice
    func setClef() {
        var hi = 0
        var lo = 9999
        for object in contents {
            if object is Chord {
                let chord = object as! Chord
                if chord.notes[0].noteValue < lo {
                    lo = chord.notes[0].noteValue
                }
                if chord.notes[chord.notes.count-1].noteValue > hi {
                    hi = chord.notes[chord.notes.count-1].noteValue
                }
            }
            if object is Note {
                let note = object as! Note
                if note.noteValue > hi {
                    hi = note.noteValue
                }
                if note.noteValue < lo {
                    lo = note.noteValue
                }
            }
        }
        let trebleRange = abs(hi - MIDDLE_C)
        let bassRange = abs(lo - MIDDLE_C)
        clef = trebleRange >= bassRange ? CLEF_TREBLE : CLEF_BASS
    }
    
    func startPlay() {
        if clef == CLEF_AUTO {
            setClef()
        }
        self.beatNum = 0
        self.lastSound = nil
    }
    
    func add(object: StaffObject) {
        contents.append(object)
    }
    
    func addObjects(objects: [StaffObject]) {
        for object in objects {
            contents.append(object)
        }
    }
    
    func isFinishedPlaying() -> Bool {
        return self.beatNum >= self.contents.count && self.lastSound == nil    }
    
    func play() {
        //println("beat \(self.beatNum)")
        if self.lastSound != nil {
            //for note in self.lastSound!.notes {
            //    instrument.stopNote(note)
            //}
            instrument.stop(lastSound!)
            self.lastSound = nil
        }
        if self.beatNum >= self.contents.count {
            return
        }
        //for note in contents[self.beatNum].notes {
        //    instrument.playNote(note)
        //}
        instrument.play(contents[beatNum])
        self.lastSound = self.contents[self.beatNum]
        self.beatNum += 1
    }
}

var staffNo = 0

//A staff represents a collection of voices
class Staff {
    var voices = [Voice]()
    var beatNum = 0
    var timer = NSTimer()
    var tempo : Double = 0.0
    var id :Int
    var stopForced : Bool
    
    init () {
        id = staffNo
        staffNo += 1
        stopForced = false
    }
    
    deinit {
        Logger.log("Staff deinit")
    }
    
    func setTempo(tempo : Double) {
        self.tempo = tempo
    }
    
    func addVoice(voice : Voice) {
        voices.append((voice))
    }
    
    func forceStop() {
        //self.timer.invalidate()
        stopForced = true
    }
    
    @objc func beat() {
        //println("====> Staff beat before play \(beatNum)")
        var done : Bool = true
        for voice in voices {
            if !voice.isFinishedPlaying() {
                voice.play()
                done = false
            }
        }
        beatNum += 1
        if done || stopForced {
            //self.timer.invalidate()
        }
        else {
            //println("====> Staff beat start timer \(beatNum)")
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.tempo, target: self, selector: Selector("beat"), userInfo: nil, repeats: false)
            //println("====> Staff beat after timer \(beatNum)")
        }
    }
    
    func play() {
        beatNum = 0
        for voice in voices {
            voice.startPlay()
        }
        self.beat()
    }
    

    
}