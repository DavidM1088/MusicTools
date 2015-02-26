let SCALE_MAJOR=0

class Scale {
    var offsets: [Int]
    
    init(type: Int) {
        offsets = [0]
        if type == SCALE_MAJOR {
            offsets = [0, 2, 4, 5, 7, 9, 11]
        }

    }
    
    class func chordTypeAtPosition(pos : Int) -> Int {
        var type = CHORD_MAJOR
        switch (pos) {
        case 2, 4, 9:
            type = CHORD_MINOR
        case 11:
            type = CHORD_DIMINISHED
        default:
            type = CHORD_MAJOR
        }
        return type
    }

}