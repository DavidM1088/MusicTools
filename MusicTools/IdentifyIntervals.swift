import UIKit

class IdentifyIntervals: UIViewController {

    var sampler = MIDISampler.sharedInstance
    var selectedTonics = SelectedTonics.sharedInstance
    var lastNote1 : Note?
    var lastNote2 : Note?
    
    var runningStaff : Staff?

    @IBOutlet weak var sliderSpeed: UISlider!
    
    @IBOutlet weak var stepperOctave: UIStepper!
    
    @IBOutlet weak var btnRepeatClicked: UIButton!
    
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
            var tempo = self.sliderSpeed.maximumValue - self.sliderSpeed.value
            runningStaff!.setTempo(Double(tempo))
        }
    }
    
    func playInterval(note1 : Note, note2 :Note) {
        var staff = self.getStaff()
        var inst1 = Instrument(sam: self.sampler.sampler0)
        let voice1 : Voice = Voice(instr: inst1)
        staff.addVoice(voice1)
        
        voice1.add(note1)
        voice1.add(note2)
        staff.play()
    }

    @IBAction func btnRepeatClicked(sender: AnyObject) {
        self.playInterval(self.lastNote1!, note2 : self.lastNote2!)
    }
    
    @IBAction func btnPlayClicked(sender: AnyObject) {
        if self.selectedTonics.selectedCount() == 0 {
            AppDelegate.userMessage("no interval roots selected")
            return
        }
        var tonic = 0
        while true {
            let index = Int(rand()) % self.selectedTonics.selected.count
            if self.selectedTonics.selected[index] {
                tonic = self.selectedTonics.selectedNotes[index]
                break
            }
        }
        tonic += Int(self.stepperOctave.value) * 12
        var note1 = Note(noteValue: tonic)
        var note2 = Note(noteValue: tonic+4)
        self.playInterval(Note(note: note1), note2: Note(note: note2))
        self.lastNote1 = note1
        self.lastNote2 = note2
        self.btnRepeatClicked.enabled = true
    }
}