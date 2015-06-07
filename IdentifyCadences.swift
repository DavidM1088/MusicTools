import UIKit

class IdentifyCadences: UIViewController {
    var selectedTonics = SelectedTonics.sharedInstance
    var selectedIntervals = SelectedIntervals.sharedInstance
    var runningStaff : Staff?
    
    @IBOutlet weak var uiViewStaff: StaffView!
    
    @IBOutlet weak var switchInversions: UISwitch!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: Selector("settings"))
        println("cadences loaded Sunday..")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func settings() {
        performSegueWithIdentifier("segueToSettings", sender: nil)
    }
    
    func getStaff() -> Staff {
        //this treatment of staff keeps the sounds from instruments alive until the next 'play' when
        //the previous staff gets destroyed (deinit'd). Staff keeps a reference to notes that keeps them alive
        //(and therefore attached to the audio engine)
        if self.runningStaff != nil {
            self.runningStaff!.forceStop()
        }
        self.runningStaff = Staff()
        self.runningStaff!.setTempo(Double(1))
        return runningStaff!
    }

    @IBAction func nextClicked(sender: AnyObject) {
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice : Voice = Voice(instr: inst1)
        staff.addVoice(voice)
        
        //figure out the notes we can use at this root offset in the scale
        let chordRoots = Scale(type: SCALE_MAJOR).offsets
        let rootNote = chordRoots[Int(rand()) % chordRoots.count]
        var base = MIDDLE_C + 5
        let tonicChord:Chord = Chord(root: base, type: CHORD_MAJOR)
        voice.add(tonicChord)
        
        var chType: Int = Scale.chordTypeAtPosition(rootNote)
        let baseChord:Chord = Chord(root: base + rootNote, type: chType)
        voice.add(baseChord)
        
        let expandedSize = 4
        let expandedChord = Chord.expandChord(baseChord, size: expandedSize)
        voice.add(expandedChord)
        
        let expandedTonic = Chord.expandChord(tonicChord, size: expandedSize)
        let leadedTonic = Chord.voiceLead(expandedChord, chord2: expandedTonic)
        voice.add(leadedTonic)
        voice.add(expandedTonic)
        voice.add(Rest())
        
        staff.play()
        self.uiViewStaff.setStaff(staff, staffMode: STAFF_DOUBLE_STAFF)
        self.uiViewStaff.setNeedsDisplay()
    }

    @IBAction func scaleClicked(sender: AnyObject) {
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: inst1)
        staff.addVoice(voice1)
        //let voice2 : Voice = Voice(instr: inst1)
        //staff.addVoice(voice2)
        
        let scale: Scale = Scale(type: SCALE_MAJOR)
        var base = 60
        for oct in 0...0 {
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
        self.uiViewStaff.setStaff(staff, staffMode: STAFF_SINGLE_STAFF)
        self.uiViewStaff.setNeedsDisplay()
    }
    
    @IBAction func cadencesClicked(sender: AnyObject) {
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        var inst2 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: inst1)
        let voice2 : Voice = Voice(instr: inst2)
        staff.addVoice(voice1)
        staff.addVoice(voice2)
        let base : Int = 60 
        let progression = [0, 5, 7, 0]
        
        for tonic in 0...0 {
            var lastChord : Chord?
            for chordIndex in progression {
                var root = base + tonic + chordIndex
                var chordType = Scale.chordTypeAtPosition(chordIndex)
                //println("base \(base) index \(chordIndex) type \(chordType)")
                var chord : Chord = Chord(root: root, type: chordType)
                if self.switchInversions.on {
                    if lastChord != nil {
                        chord = Chord.voiceLead(lastChord!, chord2: chord)
                    }
                }
                //var chordNotes : [Sound] = chord.blockBass()
                voice1.add(Rest())
                voice2.add(Note(noteValue: root - 12))
                voice1.add(chord)
                voice2.add(Rest())
                lastChord = chord
            }
            for i in 0...3 {
                voice1.add(Rest())
                voice2.add(Rest())
            }
        }
        staff.play()
        self.uiViewStaff.setStaff(staff, staffMode: STAFF_SINGLE_STAFF)
        self.uiViewStaff.setNeedsDisplay()
    }
}