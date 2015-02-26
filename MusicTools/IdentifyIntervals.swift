
import UIKit

class IdentifyIntervals: UIViewController {
    var sampler = MIDISampler()
    var runningStaff : Staff?

    override func viewDidLoad() {
        super.viewDidLoad()
        println("intervals loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}