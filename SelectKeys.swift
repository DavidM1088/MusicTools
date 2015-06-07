import UIKit

class SelectKeys: UITableViewController {
    private var keys = SelectedKeys.sharedInstance
    //private var staff : Staff?
    private var lastSelectedPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("key settings loaded")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keys.keys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("key") as! UITableViewCell
        cell.textLabel?.text = self.keys.keys[indexPath.row].getName()
        
        if indexPath.row == self.keys.selected {
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
        self.keys.selected = indexPath.row
        var cell : UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
    }
}