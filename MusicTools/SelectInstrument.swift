import UIKit

class SelectInstrument: UITableViewController {
    private var instruments = SelectedInstruments.sharedInstance
    private var staff : Staff?
    private var lastSelectedPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("instr settings loaded")
    }
    
    func getStaff() -> Staff {
        if self.staff != nil {
            self.staff!.forceStop()
        }
        self.staff = Staff()
        staff?.setTempo(1)
        return staff!
    }
    
    @IBAction func btnPlayClicked(sender: UIButton) {
        let id :String = sender.titleForState(UIControlState.Selected)!
        let midiId :Int = id.toInt()!
        let inst1 = Instrument(midiPresetId: midiId)
        let voice1 : Voice = Voice(instr: inst1)
        var staff = getStaff()
        staff.addVoice(voice1)
        voice1.add(Note(noteValue: 64))
        voice1.add(Rest())
        staff.play()
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.instruments.instruments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("instrument") as! UITableViewCell
        cell.textLabel?.text = self.instruments.instruments[indexPath.row].name

        //store the midi id in the button title so we can retrieve the midi id on button push
        var btnPlay : UIButton = cell.viewWithTag(10) as! UIButton!
        var midiId = "\(self.instruments.instruments[indexPath.row].id)"
        btnPlay.setTitle(midiId, forState: UIControlState.Selected)

        if indexPath.row == self.instruments.selected {
            cell.accessoryType = .Checkmark
            self.lastSelectedPath = indexPath
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.lastSelectedPath != nil {
            if self.tableView.cellForRowAtIndexPath(self.lastSelectedPath!) == nil {
                //println("----------> cell for last path is nil \(self.lastSelectedPath)")
                //previous selected row is scrolled out of view?
            }
            else {
                var lastCell : UITableViewCell = self.tableView.cellForRowAtIndexPath(self.lastSelectedPath!)!
                lastCell.accessoryType = .None
            }
        }
        self.lastSelectedPath = indexPath
        self.instruments.selected = indexPath.row
        var cell : UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
        //cell.n
    }
}