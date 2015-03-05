import UIKit

class IdentifyIntervals: UIViewController {
    var selectedTonics = SelectedTonics.sharedInstance
    var selectedIntervals = SelectedIntervals.sharedInstance
    
    var lastTonic : Int?
    var lastInterval : Int?
    
    var runningStaff : Staff?

    @IBOutlet weak var sliderSpeed: UISlider!
    
    @IBOutlet weak var stepperOctave: UIStepper!
    
    @IBOutlet weak var btnRepeatClicked: UIButton!
    
    @IBOutlet weak var lblIntervalAnswer: UILabel!
    

    @IBOutlet weak var uiViewStaff: StaffView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnSettings = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: Selector("settings"))
        self.navigationItem.rightBarButtonItem = btnSettings
        stepperOctave.value = 0
        stepperOctave.minimumValue = -2
        stepperOctave.maximumValue = 3
        stepperOctave.stepValue = 1
        self.btnRepeatClicked.enabled = false
        self.lblIntervalAnswer.hidden = true
        println("intervals loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func stepperOctaveClicked(sender: AnyObject) {
        //self.octave = self.octave - 1
    }
    
    func settings() {
        println("go to settings")
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
        setTempo()
        return runningStaff!
    }
    
    
    func setTempo() {
        if runningStaff != nil {
            var tempo = self.sliderSpeed.maximumValue - self.sliderSpeed.value
            runningStaff!.setTempo(Double(tempo))
        }
    }
    
    func playInterval(note1 : Note, note2 :Note) {
        var staff = self.getStaff()
        var inst1 = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice : Voice = Voice(instr: inst1)
        staff.addVoice(voice)
        let tempo = self.sliderSpeed.maximumValue - self.sliderSpeed.value
        if tempo == 0 {
            let chord = Chord(noteValues: [note1.noteValue, note2.noteValue])
            voice.add(chord)
            staff.setTempo(1)
        }
        else {
            voice.add(note1)
            voice.add(note2)
        }
        voice.add(Rest())

        staff.play()
        self.uiViewStaff.setStaff(staff, staffMode: STAFF_SINGLE_STAFF)
        self.uiViewStaff.setNeedsDisplay()
    }

    @IBAction func btnRepeatClicked(sender: AnyObject) {
        self.playInterval(Note(noteValue: self.lastTonic!),
            note2 : Note(noteValue: self.lastTonic! + self.lastInterval!))
    }
    
    @IBAction func btnPlayClicked(sender: AnyObject) {
        if self.selectedTonics.selectedCount() == 0 {
            AppDelegate.userMessage("No interval roots selected")
            return
        }
        if self.selectedIntervals.selectedCount() == 0 {
            AppDelegate.userMessage("No intervals selected")
            return
        }
        let totalCombinations = self.selectedTonics.selectedCount() * self.selectedIntervals.selectedCount()
        
        var tonic = 0
        var interval = 0
        while true {
            //get root
            while true {
                let index = Int(rand()) % self.selectedTonics.selected.count
                if self.selectedTonics.selected[index] {
                    tonic = self.selectedTonics.selectedNotes[index]
                    tonic += Int(self.stepperOctave.value) * 12
                    break
                }
            }
            //get interval
            while true {
                let index = Int(rand()) % self.selectedIntervals.selected.count
                if self.selectedIntervals.selected[index] {
                    interval = self.selectedIntervals.intervals[index].interval
                    break
                }
            }
            if totalCombinations == 1 {
                break
            }
            else {
                //dont repeat the last one
                if tonic != self.lastTonic || interval != self.lastInterval {
                    break
                }
            }
        }
        
        var note1 = Note(noteValue: tonic)
        var note2 = Note(noteValue: tonic + interval)
        self.playInterval(Note(note: note1), note2: Note(note: note2))
        
        self.lblIntervalAnswer.text = self.selectedIntervals.intervals[interval].name
        self.lblIntervalAnswer.hidden = false
        
        self.lastTonic = tonic
        self.lastInterval = interval
        self.btnRepeatClicked.enabled = true
    }
}