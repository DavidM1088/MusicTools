import UIKit

class SelectIntervals: UITableViewController {
    var selectedIntervals = SelectedIntervals.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("interval settings loaded")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedIntervals.intervals.count
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