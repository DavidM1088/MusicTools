import UIKit

class IdentifyCadences: UIViewController {
    private var selectedTonics = SelectedTonics.sharedInstance
    private var selectedIntervals = SelectedIntervals.sharedInstance
    private var runningStaff : Staff?
    private var lastChordDescription : String
    private var keyIndex : Int = 0
    
    @IBOutlet weak var uiViewStaff: StaffView!
    
    //@IBOutlet weak var switchInversions: UISwitch!
    
    @IBOutlet weak var result: UILabel!
    
    @IBOutlet weak var showRootPos: UISwitch!
    @IBOutlet weak var multipleKeys: UISwitch!
    
    required init(coder aDecoder: NSCoder) {
        lastChordDescription = ""
        super.init(coder: aDecoder)
    }
    
    @IBAction func showChord(sender: AnyObject) {
        result.text = lastChordDescription
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: Selector("settings"))
        println("cadences loaded Sunday..")
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)
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
        result.text = ""
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voiceTreble : Voice = Voice(instr: inst1, clef: CLEF_TREBLE)
        let voiceBass : Voice = Voice(instr: inst1, clef: CLEF_BASS)
        staff.addVoice(voiceTreble)
        staff.addVoice(voiceBass)
        var notesInChord = 3
        
        //figure out the notes we can use at this root offset in the scale
        let scaleOffsets = Scale(type: SCALE_MAJOR).offsets
        
        //pick a key
        var key : KeySignature
        if (self.multipleKeys.on) {
            key = KeySignature.getCommonKeys()[self.keyIndex]
            if (keyIndex < KeySignature.getCommonKeys().count - 1) {
                keyIndex += 1
            }
            else {
                keyIndex = 0
            }
            
        }
        else {
            key = SelectedKeys.getSelectedKey()
        }
        var base = key.rootNote
        
        let tonicChord:Chord = Chord(root: base, type: CHORD_MAJOR)
        voiceTreble.add(tonicChord)
        voiceBass.add(Note(noteValue: base - 1 * OCTAVE_OFFSET))
        
        // pick a random offset in the scale as the chord root
        var scaleNote = scaleOffsets[Int(rand()) % scaleOffsets.count]
        var chType: Int = Scale.chordTypeAtPosition(scaleNote)
        var trebleChord:Chord = Chord(root: base + scaleNote, type: chType)

        if (self.showRootPos.on) {
            voiceTreble.add(voiceTreble.putOnStaff(trebleChord))
            var bassNote = base + scaleNote - 1 * OCTAVE_OFFSET
            if (bassNote > MIDDLE_C) {
                bassNote -= OCTAVE_OFFSET
            }
            voiceBass.add(Note(noteValue: bassNote))
        }
        
        var inversions = Int(rand()) % notesInChord
        if (inversions > 0) {
            for i in 0...inversions-1 {
                trebleChord = Chord.invert(trebleChord)
            }
        }
        
        //remove a note from the treble chord and add it to the base chord
        let removeIndex = Int(rand()) % trebleChord.notes.count
        let removedFromTreble = trebleChord.notes[removeIndex].noteValue
        trebleChord = Chord.removeNote(trebleChord, noteNum: removeIndex)
        
        var baseNotes : [Int] = []
        baseNotes.append(base + scaleNote - 2 * OCTAVE_OFFSET)  // add the chord root
        baseNotes.append(removedFromTreble - 2 * OCTAVE_OFFSET) //add the note remvoed from the treble
        var bassChord : Chord = Chord(noteValues: baseNotes)

        //make the root not always the lowest bass chord note
        inversions = Int(rand()) % baseNotes.count
        if (inversions > 0) {
            for i in 0...inversions-1 {
                bassChord = Chord.invert(bassChord)
            }
        }
        
        voiceTreble.add(voiceTreble.putOnStaff(trebleChord))
        voiceBass.add(voiceBass.putOnStaff(bassChord))
        
        lastChordDescription = "\(Chord.romanNumeralNotation(scaleNote))"
        staff.play()
        self.uiViewStaff.setStaff(staff, key: key)
        self.uiViewStaff.setNeedsDisplay()
    }
    
    @IBAction func nextClicked_test(sender: AnyObject) {
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: inst1, clef: CLEF_TREBLE)
        let voice2 : Voice = Voice(instr: inst1, clef: CLEF_BASS)
        staff.addVoice(voice1)
        staff.addVoice(voice2)
        
        voice1.add(Note(noteValue: MIDDLE_C + 0))
        voice1.add(Note(noteValue: MIDDLE_C - 3))
        voice2.add(Note(noteValue: MIDDLE_C + 0))
        voice2.add(Note(noteValue: MIDDLE_C + 4)) 
        //voice1.add(Rest())
        voice2.add(Rest())
        
        staff.play()
        self.uiViewStaff.setStaff(staff, key: SelectedKeys.getSelectedKey())
        self.uiViewStaff.setNeedsDisplay()
    }

    @IBAction func scaleClicked(sender: AnyObject) {
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: inst1, clef: CLEF_AUTO)
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
        self.uiViewStaff.setStaff(staff, key: SelectedKeys.getSelectedKey())
        self.uiViewStaff.setNeedsDisplay()
    }
    
    @IBAction func cadencesClicked(sender: AnyObject) {
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        var inst2 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: inst1, clef: CLEF_AUTO)
        let voice2 : Voice = Voice(instr: inst2, clef: CLEF_AUTO)
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
                if lastChord != nil {
                    chord = Chord.voiceLead(lastChord!, chord2: chord)
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
        self.uiViewStaff.setStaff(staff, key: SelectedKeys.getSelectedKey())
        self.uiViewStaff.setNeedsDisplay()
    }
}