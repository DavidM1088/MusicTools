 import Foundation
import UIKit

let STAFF_DOUBLE_STAFF = 0 //show treble and bass
let STAFF_SINGLE_STAFF = 1 //either treble or bass but not both

let STAFF_TREBLE = 0
let STAFF_BASE = 1

class StaffView : UIView {
    private var staff : Staff?
    private var staffMode : Int = STAFF_DOUBLE_STAFF
    private let lineSpace : CGFloat = 12.0

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
        //CGContextAddEllipseInRect(ctx, accRect)
        //CGContextFillPath(ctx)
    }

    //the space offset on the staff of this note from middle C
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
    
    private func renderObject(ctx : CGContext, object : StaffObject, key : KeySignature, xPos : CGFloat, middleCPos : CGFloat, lineRange : (Int, Int)) {
        var accidental = ACCIDENTAL_NONE
        var presentation : NotePresentation?
        
        if object is Note {
            let note : Note = object as Note
            presentation = key.notePresentation(note.noteValue)
            //println("View...\(notePresentation.toString())")
            accidental = presentation!.accidental
        }
        if object is Accidental {
            let acc = object as Accidental
            accidental = acc.type
            presentation = key.notePresentation(acc.midiOffset)
        }
        
        let offsetLines = self.offsetFromC(presentation!)

        for var index = -20; index < 20; index++ {
            let ypos : CGFloat = middleCPos + CGFloat(index) * lineSpace/2
            let noteWidth = 2 * lineSpace
            if index == offsetLines {
                if accidental != ACCIDENTAL_NONE {
                    self.drawAccidental(ctx, accidental: accidental, x: xPos - 14, y: ypos, height: lineSpace * 1.5, width : noteWidth)
                }
                if object is Note {
                    self.drawNote(ctx, x: xPos, y: ypos, height: lineSpace, width : noteWidth)
                }
            }
            // partially draw in any missing ledger lines for the note if its above or below the 5 staff lines
            if index % 2 == 0 {
                if (offsetLines > lineRange.1 && index <= offsetLines && index > lineRange.1) ||
                    (offsetLines < lineRange.0 && index >= offsetLines && index < lineRange.0) {
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
        let trebleRange = abs(hiLo.1 - MIDDLE_C)
        let bassRange = abs(hiLo.0 - MIDDLE_C)
        let clefToShow = trebleRange >= bassRange ? STAFF_TREBLE : STAFF_BASE
        
        //set the context to (0,0) at bottom left
        var ctx = UIGraphicsGetCurrentContext()
        var transform : CGAffineTransform = CGAffineTransformMakeTranslation(0.0, rect.height)
        transform = CGAffineTransformScale(transform, 1.0, -1.0) //switch origin to bottom left since images render upside down otherwise
        CGContextConcatCTM(ctx, transform)

        //draw staff lines
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
            middleCPos = clefToShow == STAFF_TREBLE ? (CGFloat(midLine - 6) * lineSpace) + centerLine : (CGFloat(6 - midLine) * lineSpace) + centerLine
        }
        
        CGContextStrokePath(ctx)
        
        // draw the clef
        let clefHeight : CGFloat = clefToShow == STAFF_TREBLE ? 6 * lineSpace + lineSpace/1.5 : 4.5 * lineSpace
        let clefWidth = clefHeight / 2.0
        var clefImage : UIImage = clefToShow == STAFF_TREBLE ? UIImage(named: "treble_clef.png")! : UIImage(named: "bass_clef.png")!
        var clefOffset  : CGFloat = clefToShow == STAFF_TREBLE ? CGFloat(middleCPos - lineSpace/2) : CGFloat(middleCPos - lineSpace * 5)
        let clefRect = CGRect(x: xPos, y: clefOffset, width: clefWidth, height: clefHeight)
        CGContextDrawImage(ctx, clefRect, clefImage.CGImage)
        xPos += clefWidth
        xPos += 24
        
        //draw the key signature
        let lineRange : (Int, Int) = clefToShow == STAFF_TREBLE ? (2, 10) : (-10, -2)
        let key = SelectedKeys.getSelectedKey()
        let (sharp, accidentals) = key.getAccidentals(clefToShow)

        for accidental in accidentals {
            let type = sharp ? ACCIDENTAL_SHARP : ACCIDENTAL_FLAT
            let acc = Accidental(midiOffset: accidental, type: type)
            self.renderObject(ctx, object: acc, key: key, xPos: xPos, middleCPos : middleCPos, lineRange: lineRange)
            xPos += 12
        }
        xPos += 24
        
        // draw the notes in the voices
        for voice in self.staff!.voices {
            var x : CGFloat = xPos
            for object in voice.contents {
                if object is Chord {
                    let chord : Chord = object as Chord
                    for note in chord.notes {
                        self.renderObject(ctx, object: note, key: key, xPos: x, middleCPos : middleCPos, lineRange: lineRange)
                    }
                }
                if object is Note {
                    let note : Note = object as Note
                    self.renderObject(ctx, object: note, key: key, xPos: x, middleCPos : middleCPos, lineRange: lineRange)
                    
                }
                x += 50
            }
        }
    }
}
