import UIKit

class SelectTonics: UITableViewController {
    var selectedTonics = SelectedTonics.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("keys settings loaded")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedTonics.selectedNotes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("keyId") as UITableViewCell
        cell.textLabel?.text = self.selectedTonics.selectedNoteNames[indexPath.row]
        if self.selectedTonics.selected[indexPath.row] {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println("keyselected..\(self.items[indexPath.row]) ")
        var cell : UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            self.selectedTonics.selected[indexPath.row] = true
        }
        else {
            cell.accessoryType = .None
            self.selectedTonics.selected[indexPath.row] = false
        }

    }
}