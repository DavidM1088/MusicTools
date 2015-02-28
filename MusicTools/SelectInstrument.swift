import UIKit

class SelectInstrument: UITableViewController {
    var instruments = SelectedInstruments.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("instr settings loaded")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.instruments.instruments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("instrument") as UITableViewCell
        cell.textLabel?.text = self.instruments.instruments[indexPath.row].name
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
        MIDISampler.sharedInstance.loadInstrument(0, instr: self.instruments.instruments[indexPath.row].id)
        //self.lastSelected = indexPath
        
    }
}