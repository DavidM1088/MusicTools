import Foundation

class Interval {
    var name : String
    var interval : Int
    init (name : String, interval : Int) {
        self.name = name
        self.interval = interval
    }
}

class SelectedIntervals {
    var intervals: [Interval] = []
    var selected :[Bool] = []
    
    init() {
        self.intervals.append(Interval(name: "Major 2nd", interval: 2))
        self.intervals.append(Interval(name: "Minor 3rd", interval: 3))
        selected[0] = true
    }
    
    class var sharedInstance: SelectedIntervals {
        struct Singleton {
            static let instance = SelectedIntervals()
        }
        return Singleton.instance
    }
    
    func selectedCount() -> Int {
        var total : Int = 0
        for sel in self.selected {
            if sel {
                total += 1
            }
        }
        return total
    }
}