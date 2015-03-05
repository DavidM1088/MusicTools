import UIKit

class IdentifyIntervalsSettings: UITableViewController {
    var items: [String] = ["Intervals", "Interval Root Notes", "Instruments"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let btnSettings = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: Selector("settings"))
        //self.navigationItem.rightBarButtonItem = btnSettings
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        //self.tableView.delegate = self
        //self.tableView.dataSource = self

        println("intervals settings loaded")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellType : String?
        switch (indexPath.row) {
            case 0: cellType = "intervalsSettingsRow"
            case 1: cellType = "rootsSettingsRow"
            case 2: cellType = "instrumentsSettingsRow"
            default : cellType = nil
        }
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellType!) as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        //cell.detailTextLabel?.text = "detail"
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}