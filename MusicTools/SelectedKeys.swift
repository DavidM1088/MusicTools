import Foundation

class SelectedKeys {
    
    var keys : [KeySignature]
    var selected : Int
    
    init() {
        self.keys  = []
        //majors
        keys.append(KeySignature(root: "C", type: KEY_MAJOR, sharps: 0, flats: 0, rootNote: MIDDLE_C))
        
        keys.append(KeySignature(root: "G", type: KEY_MAJOR, sharps: 1, flats: 0, rootNote: MIDDLE_C + 7))
        keys.append(KeySignature(root: "F", type: KEY_MAJOR, sharps: 0, flats: 1, rootNote: MIDDLE_C + 5))
        keys.append(KeySignature(root: "D", type: KEY_MAJOR, sharps: 2, flats: 0, rootNote: MIDDLE_C + 2))
        keys.append(KeySignature(root: "Bb", type: KEY_MAJOR, sharps: 0, flats: 2, rootNote: MIDDLE_C + 10))
        
        keys.append(KeySignature(root: "A", type: KEY_MAJOR, sharps: 3, flats: 0, rootNote: MIDDLE_C + 9))
        keys.append(KeySignature(root: "Eb", type: KEY_MAJOR, sharps: 0, flats: 3, rootNote: MIDDLE_C + 3))
        keys.append(KeySignature(root: "E", type: KEY_MAJOR, sharps: 4, flats: 0, rootNote: MIDDLE_C + 4))
        keys.append(KeySignature(root: "Ab", type: KEY_MAJOR, sharps: 0, flats: 4, rootNote: MIDDLE_C + 8))
        
        keys.append(KeySignature(root: "B", type: KEY_MAJOR, sharps: 5, flats: 0, rootNote: MIDDLE_C + 11))
        keys.append(KeySignature(root: "Db", type: KEY_MAJOR, sharps: 0, flats: 5, rootNote: MIDDLE_C + 1))
        keys.append(KeySignature(root: "F#", type: KEY_MAJOR, sharps: 6, flats: 0, rootNote: MIDDLE_C + 6))
        keys.append(KeySignature(root: "Gb", type: KEY_MAJOR, sharps: 0, flats: 6, rootNote: MIDDLE_C + 6))
        
        //minors
        keys.append(KeySignature(root: "A", type: KEY_MINOR, sharps: 0, flats: 0, rootNote: MIDDLE_C + 9))
        keys.append(KeySignature(root: "E", type: KEY_MINOR, sharps: 1, flats: 0, rootNote: MIDDLE_C + 4))
        keys.append(KeySignature(root: "D", type: KEY_MINOR, sharps: 0, flats: 1, rootNote: MIDDLE_C + 2))
        selected = 6
    }
    
    class var sharedInstance: SelectedKeys {
        struct Singleton {
            static let instance = SelectedKeys()
        }
        return Singleton.instance
    }
    
    class func getSelectedKey() -> KeySignature {
        return sharedInstance.keys[sharedInstance.selected]
    }
    
    class func getKeyList() -> [KeySignature] {
        return sharedInstance.keys
    }

}