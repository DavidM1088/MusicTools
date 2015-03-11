import Foundation
import UIKit

let STAFF_DOUBLE_STAFF = 0 //show treble and bass
let STAFF_SINGLE_STAFF = 1 //either treble or bass but not both

class StaffView : UIView {
    private var staff : Staff?
    private var staffMode : Int = STAFF_DOUBLE_STAFF
    private let lineSpace : CGFloat = 12.0
    
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
    
    private func drawNote(ctx : CGContext, x : CGFloat, y : CGFloat, height : CGFloat, width : CGFloat ) {
        let offset = height / 2.0
        let rect : CGRect = CGRect(origin: CGPoint(x: x, y: y - height/2), size: CGSize(width: width, height: height))
        CGContextAddEllipseInRect(ctx, rect)
        //CGContextStrokePath(ctx)
        CGContextFillPath(ctx)
    }
    
    private func drawAccidental(ctx : CGContext, accidental : Int, x : CGFloat, y : CGFloat, height : CGFloat, width : CGFloat ) {
        var accImage : UIImage? = nil
        switch (accidental) {
            case ACCIDENTAL_FLAT: accImage = UIImage(named: "flat.png")!
            case ACCIDENTAL_SHARP: accImage = UIImage(named: "sharp.png")!
            case ACCIDENTAL_NATURAL: accImage = UIImage(named: "natural.png")!
            default: accImage = nil
        }
        let accRect = CGRect(x: x - width/2, y: y - height/2, width: width, height: height)
        CGContextDrawImage(ctx, accRect, accImage!.CGImage)
    }
    
    private func offsetFromC(note : NotePresentation) -> Int {
        var offset = 0
        switch (note.name) {
            case "C": offset = 0
            case "D": offset = 1
            case "E": offset = 2
            case "F": offset = 3
            case "G": offset = 4
            case "A": offset = 5
            case "B": offset = 6
        default: offset = 0
        }
        let octaveOffset = (note.octave - 4) * 7
        return offset + octaveOffset
    }
    
    private func drawNote(ctx : CGContext, note : Note, key : KeySignature, xPos : CGFloat, middleCPos : CGFloat) {
        let notePresentation = key.notePresentation(note.noteValue)
        println("View...\(notePresentation.toString())")
        let noteOffset = self.offsetFromC(notePresentation)
        for var index = -8; index < 20; index++ {
            let ypos : CGFloat = middleCPos + CGFloat(index) * lineSpace/2
            let noteWidth = 2 * lineSpace
            if index == noteOffset {
                if notePresentation.accidental != ACCIDENTAL_NONE {
                    self.drawAccidental(ctx, accidental: notePresentation.accidental, x: xPos - 14, y: ypos+4, height: lineSpace * 1.5, width : noteWidth)
                }
                self.drawNote(ctx, x: xPos, y: ypos, height: lineSpace, width : noteWidth)
            }
            // partially draw in any missing ledger lines for the note
            if index % 2 == 0 {
                if (index <= 0 && index >= noteOffset) || (index > 0 && index <= noteOffset) {
                    CGContextMoveToPoint(ctx, xPos - 4, ypos)
                    CGContextAddLineToPoint(ctx, xPos + noteWidth + 4, ypos)
                    CGContextStrokePath(ctx)
                }
            }
        }
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
        var transform : CGAffineTransform = CGAffineTransformMakeTranslation(0.0, rect.height)
        transform = CGAffineTransformScale(transform, 1.0, -1.0) //switch origin to bottom left since images render upside down otherwise
        CGContextConcatCTM(ctx, transform)

        let centerLine : CGFloat = rect.height / 2.0
        var xPos : CGFloat = 10.0
        var middleCPos :CGFloat = 0
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.50)
        if self.staffMode == 0 {
            //double staff
        }
        else {
            let midLine = 3
            for line : Int in 1...5 {
                let rowAt : CGFloat = (CGFloat(midLine - line) * lineSpace) + centerLine
                CGContextMoveToPoint(ctx, xPos, rowAt)
                CGContextAddLineToPoint(ctx, rect.width - xPos, rowAt)
            }
            middleCPos = (CGFloat(midLine - 6) * lineSpace) + centerLine
        }
        CGContextStrokePath(ctx)
        
        // draw the clef and key signature
        let clefHeight : CGFloat = 6 * lineSpace + lineSpace/1.5
        let clefWidth = clefHeight / 2.0
        var clefImage : UIImage = UIImage(named: "treble_clef.png")!
        var clefOffset  : CGFloat = CGFloat(middleCPos - lineSpace/2)
        let clefRect = CGRect(x: xPos, y: clefOffset, width: clefWidth, height: clefHeight)
        CGContextDrawImage(ctx, clefRect, clefImage.CGImage)
        xPos += clefWidth
        xPos += 32
        
        // draw the notes for each voice
        let key = KeySignature.getSelectedKey()
        
        for voice in self.staff!.voices {
            var x : CGFloat = xPos
            for object in voice.contents {
                if object is Chord {
                    let chord : Chord = object as Chord
                    for note in chord.notes {
                        self.drawNote(ctx, note: note, key: key, xPos: x, middleCPos : middleCPos)
                    }
                }
                if object is Note {
                    let note : Note = object as Note
                    self.drawNote(ctx, note: note, key: key, xPos: x, middleCPos : middleCPos)
                    
                }
                x += 50
            }
        }
    }
}
