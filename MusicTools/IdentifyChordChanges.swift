
import UIKit

class IdentifyChordChanges: UIViewController {
    var audioEngine = AudioEngine.sharedInstance
    var runningStaff : Staff?
    
    @IBOutlet weak var switchInversions: UISwitch!
    
    @IBOutlet weak var sliderTempo: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sliderTempo.minimumValue = 0.3
        self.sliderTempo.maximumValue = 1.0
        let btnSettings = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: Selector("settings"))
        self.navigationItem.rightBarButtonItem = btnSettings
    }


    func settings() {
        print("go to settings")
        performSegueWithIdentifier("segueToSettings", sender: nil)
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
        setTempo()
        //runningStaff!.setTempo(0.5)
        return runningStaff!
    }
    
    func setTempo() {
        if runningStaff != nil {
            let tempo = self.sliderTempo.maximumValue - self.sliderTempo.value
            runningStaff!.setTempo(Double(tempo))
        }
    }
    
    @IBAction func sliderTempoChanged(sender: AnyObject) {
        self.setTempo()
    }
    
    @IBAction func btnStopClicked(sender: AnyObject) {
        if  self.runningStaff != nil {
            self.runningStaff!.forceStop()
            self.runningStaff = nil
        }
        //sampler.loadInstruments() //resets all sounds ..
    }
    
    @IBAction func btnPlayClicked(sender: AnyObject) {
        let staff = self.getStaff()
        let inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: inst1, clef: CLEF_AUTO)
        staff.addVoice(voice1)
        //let voice2 : Voice = Voice(instr: inst1)
        //staff.addVoice(voice2)
        
        let scale: Scale = Scale(type: SCALE_MAJOR)
        var base = 52
        for oct in 0...2 {
            for offset in scale.offsets {
                let chType: Int = Scale.chordTypeAtPosition(offset)
                print("offset \(offset) type \(chType)")
                let chord:Chord = Chord(root: base + offset, type: chType, seventh:false)
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
        let staff = self.getStaff()
        let inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let inst2 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: inst1, clef: CLEF_AUTO)
        let voice2 : Voice = Voice(instr: inst2, clef: CLEF_AUTO)
        staff.addVoice(voice1)
        staff.addVoice(voice2)
        let base : Int = 64 - 12
        
        for tonic in 0...5 {
            var lastChord : Chord?
            for chordIndex in progression {
                let root = base + tonic + chordIndex
                let chordType = Scale.chordTypeAtPosition(chordIndex)
                //println("base \(base) index \(chordIndex) type \(chordType)")
                var chord : Chord = Chord(root: root, type: chordType, seventh:false)
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
    }
    
    @IBAction func btnBach(sender: AnyObject) {
        self.chordProgression(Progression.bach())
    }

    @IBAction func btnPachelbel(sender: AnyObject) {
        self.chordProgression(Progression.pachelbelCanon())
    }
    
    @IBAction func btnCircular(sender: AnyObject) {
        self.chordProgression(Progression.circleProgression())
    }

    @IBAction func btnProgressionClicked(sender: AnyObject) {
        let progression = Progression.blues12Bar()
        self.chordProgression(progression)
    }
}

