import UIKit

class SelectInstrument: UITableViewController {
    var instruments = SelectedInstruments.sharedInstance
    var staff : Staff?
    
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
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("instrument") as UITableViewCell
        cell.textLabel?.text = self.instruments.instruments[indexPath.row].name

        var btnPlay : UIButton = cell.viewWithTag(10) as UIButton!
        var midiId = "\(self.instruments.instruments[indexPath.row].id)"
        btnPlay.setTitle(midiId, forState: UIControlState.Selected)

        if indexPath.row == self.instruments.selected {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println("keyselected..\(self.items[indexPath.row]) ")
        let index = 3
        var path = NSIndexPath(forRow: instruments.selected, inSection: 0)
        var selectedCell : UITableViewCell = self.tableView.cellForRowAtIndexPath(path)!
        selectedCell.accessoryType = .None
        
        var cell : UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        self.instruments.selected = indexPath.row
        cell.accessoryType = .Checkmark 
        //MIDISampler.sharedInstance.loadInstrument(0, instr: self.instruments.instruments[indexPath.row].id)
        //self.lastSelected = indexPath
        
    }
}