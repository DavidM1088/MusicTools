import Foundation


class SelectedTonics {
    let selectedNotes : [Int] = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71]
    var selectedNoteNames : [String] = []
    var selected :[Bool] = []
    
    init() {
        for note in self.selectedNotes {
            selectedNoteNames.append(Note.noteDescription(Note(noteValue: note), withOctave: false))
            selected.append(false)
        }
        selected[0] = true
    }
    
    class var sharedInstance: SelectedTonics {
        struct Singleton {
            static let instance = SelectedTonics()
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