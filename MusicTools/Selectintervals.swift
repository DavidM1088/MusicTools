import UIKit

class SelectIntervals: UITableViewController {
    private var selectedIntervals = SelectedIntervals.sharedInstance
    private var staff : Staff?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("interval settings loaded")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedIntervals.intervals.count
    }
    
    func getStaff() -> Staff {
        if self.staff != nil {
            self.staff!.forceStop()
        }
        self.staff = Staff()
        staff?.setTempo(1)
        return staff!
    }
    
    @IBAction func btnPlayClciked(sender: UIButton) {
        let id :String = sender.titleForState(UIControlState.Selected)!
        let intervalRange :Int = id.toInt()!
        var instr = Instrument(midiPresetId: SelectedInstruments.getSelectedInstrument())
        let voice1 : Voice = Voice(instr: instr)
        var staff = getStaff()
        staff.addVoice(voice1)
        var root = 64
        voice1.add(Note(noteValue: root))
        voice1.add(Note(noteValue: root + intervalRange))
        voice1.add(Rest())
        staff.play()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cellTypeId") as UITableViewCell
        cell.textLabel?.text = self.selectedIntervals.intervals[indexPath.row].name
        if self.selectedIntervals.selected[indexPath.row] {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        var btnPlay : UIButton = cell.viewWithTag(10) as UIButton!
        var intervalRange = "\(self.selectedIntervals.intervals[indexPath.row].interval)"
        btnPlay.setTitle(intervalRange, forState: UIControlState.Selected)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell : UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            self.selectedIntervals.selected[indexPath.row] = true
        }
        else {
            cell.accessoryType = .None
            self.selectedIntervals.selected[indexPath.row] = false
        }
    }
}