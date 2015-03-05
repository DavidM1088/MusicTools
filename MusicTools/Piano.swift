import Foundation

class Piano {
    class func isWhiteNote(midiNote : Int) -> Bool {
        let normalizedNote = midiNote - midiNote/Int(12)
        var isWhite : Bool = false
        switch (normalizedNote) {
        case 0, 2, 4, 5, 7, 9, 11:
            isWhite = true
        default:
            isWhite = false
        }
        return isWhite
    }
}
