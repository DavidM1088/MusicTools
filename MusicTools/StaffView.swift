import Foundation
import UIKit

let STAFF_DOUBLE_STAFF = 0 //show treble and bass
let STAFF_SINGLE_STAFF = 1 //either treble or bass but not both

class StaffView : UIView {
    private var staff : Staff?
    private var staffMode : Int = STAFF_DOUBLE_STAFF
    
    private let MIDDLE_C = 60
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setStaff(staff : Staff, staffMode : Int) {
        self.staff = staff
        self.staffMode = staffMode
    }
    
    //return highest and lowest note on the staff
    private func hiLoNotes() -> (Int, Int) {
        var hi = 0
        var lo = 9999
        for voice in self.staff!.voices {
            for object in voice.contents {
                if object is Chord {
                    let chord = object as Chord
                    if chord.notes[0].noteValue < lo {
                        lo = chord.notes[0].noteValue
                    }
                    if chord.notes[chord.notes.count-1].noteValue > hi {
                        hi = chord.notes[chord.notes.count-1].noteValue
                    }
                }
                if object is Note {
                    let note = object as Note
                    if note.noteValue > hi {
                        hi = note.noteValue
                    }
                    if note.noteValue < lo {
                        lo = note.noteValue
                    }
                }
            }
        }
        return (lo, hi)
    }
    
    func drawNote(ctx : CGContext, x : CGFloat, y : CGFloat, size : CGFloat ) {
        let offset = size / 2.0
        let rect : CGRect = CGRect(origin: CGPoint(x: x, y: y - size/2), size: CGSize(width: 2*size, height: size))
        CGContextAddEllipseInRect(ctx, rect)
        CGContextStrokePath(ctx)
    }
    
    func offsetFromC(note : String) -> Int {
        var offset = 0
        switch (note) {
            case "C": offset = 0
            case "D": offset = 1
            case "E": offset = 2
            case "F": offset = 3
            case "G": offset = 4
            case "A": offset = 5
            case "B": offset = 6
        default: offset = 0
        }
        return offset
    }
    
    override func drawRect(rect: CGRect) {
        if self.staff == nil {
            return
        }
        //determine clef to show
        let hiLo = self.hiLoNotes()
        let trebleRange = hiLo.1 - MIDDLE_C
        let bassRange = MIDDLE_C - hiLo.0
        let clefToShow = trebleRange >= bassRange ? 0 : 1
        
        //draw staff lines
        var ctx = UIGraphicsGetCurrentContext()

        let lineSpace : CGFloat = 12.0
        let centerLine : CGFloat = rect.height / 2.0
        let margin : CGFloat = 10.0
        
        var middleCPos :CGFloat = 0
        
        if self.staffMode == 0 {
            //double staff
        }
        else {
            let midLine = 3
            for line : Int in 1...5 {
                let rowAt : CGFloat = (CGFloat(line - midLine) * lineSpace) + centerLine
                CGContextMoveToPoint(ctx, margin, rowAt)
                CGContextAddLineToPoint(ctx, rect.width - margin, rowAt)
            }
            middleCPos = (CGFloat(6 - midLine) * lineSpace) + centerLine
        }
        CGContextStrokePath(ctx)
        
        // draw the notes for each voice
        let key = KeySignature.getSelectedKey()
        
        for voice in self.staff!.voices {
            var x : CGFloat = margin * 2.0
            for object in voice.contents {
                /*if object is Chord {
                    let chord = object as Chord
                    if chord.notes[0].noteValue < lo {
                        lo = chord.notes[0].noteValue
                    }
                    if chord.notes[chord.notes.count-1].noteValue > hi {
                        hi = chord.notes[chord.notes.count-1].noteValue
                    }
                } */
                if object is Note {
                    let note = object as Note
                    let pres = key.notePresentation(note.noteValue)
                    println("View...\(pres.toString())")
                    let pos : CGFloat = middleCPos - CGFloat(self.offsetFromC(pres.name)) * lineSpace/2
                    self.drawNote(ctx, x: x, y: pos, size: lineSpace)
                }
                x += 30
            }
        }
        
    }
}
