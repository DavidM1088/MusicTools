import Foundation

class Interval {
    var name : String
    var interval : Int
    var shortName : String
    init (name : String, interval : Int, shortName : String) {
        self.name = name
        self.interval = interval
        self.shortName = shortName
    }
}

class SelectedIntervals {
    var intervals: [Interval] = []
    var selected :[Bool] = []
    
    init() {
        self.intervals.append(Interval(name: "Perfect Unison", interval: 0, shortName: "P1"))
        self.intervals.append(Interval(name: "Minor 2nd", interval: 1, shortName: "m2"))
        self.intervals.append(Interval(name: "Major 2nd", interval: 2, shortName: "M2"))
        self.intervals.append(Interval(name: "Minor 3rd", interval: 3, shortName: "m3"))
        self.intervals.append(Interval(name: "Major 3rd", interval: 4, shortName: "M4"))
        self.intervals.append(Interval(name: "Perfect 4th", interval: 5, shortName: "P4"))
        self.intervals.append(Interval(name: "Diminished 5th", interval: 6, shortName: "Tritone"))
        self.intervals.append(Interval(name: "Perfect 5th", interval: 7, shortName: "P5"))
        self.intervals.append(Interval(name: "Minor 6th", interval: 8, shortName: "m6"))
        self.intervals.append(Interval(name: "Major 6th", interval: 9, shortName: "M6"))
        self.intervals.append(Interval(name: "Minor 7th", interval: 10, shortName: "m7"))
        self.intervals.append(Interval(name: "Major 7th", interval: 11, shortName: "M7"))
        self.intervals.append(Interval(name: "Octave", interval: 12, shortName: "P8"))
        for index in 0...self.intervals.count {
            selected.append(false)
        }
        selected[7] = true
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