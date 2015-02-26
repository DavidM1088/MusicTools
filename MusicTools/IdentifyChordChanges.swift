
import UIKit

class IdentifyChordChanges: UIViewController {
    var sampler = MIDISampler()
    var runningStaff : Staff?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("identify view loaded____")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getStaff() -> Staff {
        if self.runningStaff != nil {
            self.runningStaff!.forceStop()
        }
        self.runningStaff = Staff()
        //setTempo()
        runningStaff!.setTempo(0.5)
        return runningStaff!
    }
    
    @IBAction func btnStopClicked(sender: AnyObject) {
        if  self.runningStaff != nil {
            self.runningStaff!.forceStop()
            self.runningStaff = nil
        }
    }
    
    @IBAction func btnPlayClicked(sender: AnyObject) {
        var staff = self.getStaff()
        var inst1 = Instrument(sam: self.sampler.sampler0)
        let voice1 : Voice = Voice(instr: inst1)
        staff.addVoice(voice1)
        //let voice2 : Voice = Voice(instr: inst1)
        //staff.addVoice(voice2)
        
        let scale: Scale = Scale(type: SCALE_MAJOR)
        var base = 52
        for oct in 0...2 {
            for offset in scale.offsets {
                var chType: Int = Scale.chordTypeAtPosition(offset)
                println("offset \(offset) type \(chType)")
                let chord:Chord = Chord(root: base + offset, type: chType)
                voice1.add(chord)
                //voice2.addSound(Note(note: base + offset - 12, duration : NOTE_QTR))
            }
            base += 12
        }
        staff.play()
    }
    
    func chordProgression(progression : [Int]) {
        //Chord.unitTest()
        //return
        var staff = self.getStaff()
        var inst1 = Instrument(sam: self.sampler.sampler0)
        //var inst2 = Instrument(sam: self.sampler.sampler1)
        let voice1 : Voice = Voice(instr: inst1)
        staff.addVoice(voice1)
        let base : Int = 64 - 12
        
        for tonic in 0...5 {
            var lastChord : Chord?
            for chordIndex in progression {
                var root = base + tonic + chordIndex
                var chordType = Scale.chordTypeAtPosition(chordIndex)
                //println("base \(base) index \(chordIndex) type \(chordType)")
                var chord : Chord = Chord(root: root, type: chordType)
                /*if self.switchVoiceLeading.on {
                    if lastChord != nil {
                        chord = Chord.voiceLead(lastChord!, chord2: chord)
                    }
                }*/
                //var chordNotes : [Sound] = chord.blockBass()
                voice1.add(chord)
                lastChord = chord
            }
            for i in 0...3 {
                voice1.add(Rest(duration: 1.0))
            }
        }
        staff.play()
    }

    
    @IBAction func btnProgressionClicked(sender: AnyObject) {
        var progression : [Int]

        progression = Progression.blues12Bar()
        self.chordProgression(progression)
    }
}

