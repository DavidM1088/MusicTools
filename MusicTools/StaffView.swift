import Foundation
import UIKit

let STAFF_DOUBLE_STAFF = 0 //show treble and bass
let STAFF_SINGLE_STAFF = 1 //either treble or bass but not both

let STAFF_BOTH = 0
let STAFF_TREBLE = 2
let STAFF_BASE = 3

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
                    let chord = object as! Chord
                    if chord.notes[0].noteValue < lo {
                        lo = chord.notes[0].noteValue
                    }
                    if chord.notes[chord.notes.count-1].noteValue > hi {
                        hi = chord.notes[chord.notes.count-1].noteValue
                    }
                }
                if object is Note {
                    let note = object as! Note
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
            let note : Note = object as! Note
            presentation = key.notePresentation(note.noteValue)
            //println("View...\(notePresentation.toString())")
            accidental = presentation!.accidental
        }
        if object is Accidental {
            let acc = object as! Accidental
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
            // partially draw in any missing ledger lines for the note if its above or below the staff lines
            if object is Note {
                if index % 2 == 0 {
                    if (offsetLines > lineRange.1 && index <= offsetLines && index > lineRange.1) ||
                        (offsetLines < lineRange.0 && index >= offsetLines && index < lineRange.0) ||
                        (offsetLines == 0 && index==0 /* middle C in a double clef */) {
                        CGContextMoveToPoint(ctx, xPos - 4, ypos)
                        CGContextAddLineToPoint(ctx, xPos + noteWidth + 4, ypos)
                        CGContextStrokePath(ctx)
                    }
                }
            }
        }
    }
    
    func drawStaff(ctx: CGContext, centerAt: CGFloat, margin: CGFloat, width: CGFloat, staffType : Int, keySignature: KeySignature) {
        //draw the staff lines
        let midLine = 3
        for line : Int in 1...5 {
            let rowAt : CGFloat = (CGFloat(midLine - line) * lineSpace) + centerAt
            CGContextMoveToPoint(ctx, margin, rowAt)
            CGContextAddLineToPoint(ctx, width - margin, rowAt)
        }
        let middleCPos = staffType == STAFF_TREBLE ? (CGFloat(midLine - 6) * lineSpace) + centerAt : (CGFloat(6 - midLine) * lineSpace) + centerAt

        //draw the clef image
        let clefHeight : CGFloat = 5 * lineSpace
        let clefWidth = clefHeight / 2.0
        let clefRect = CGRect(x: margin, y: centerAt - clefHeight/2, width: clefWidth, height: clefHeight)
        let clefImage : UIImage = staffType == STAFF_TREBLE ? UIImage(named: "treble_clef.png")! : UIImage(named: "bass_clef.png")!
        CGContextDrawImage(ctx, clefRect, clefImage.CGImage)
        
        //draw the key signature
        let accidentals = keySignature.getAccidentals(staffType)
        let accidentalType = keySignature.getAccidentalType()
        var xKeySigPos = margin + clefWidth
        xKeySigPos += 24
        for accidental in accidentals {
            let acc = Accidental(midiOffset: accidental, type: accidentalType)
            self.renderObject(ctx, object: acc, key: keySignature, xPos: xKeySigPos, middleCPos : middleCPos, lineRange: (0,0))
            xKeySigPos += 24
        }
    }
    
    override func drawRect(rect: CGRect) {
        if self.staff == nil {
            return
        }
        //determine clef to show based on notes to show
        let hiLo = self.hiLoNotes()
        let trebleRange = abs(hiLo.1 - MIDDLE_C)
        let bassRange = abs(hiLo.0 - MIDDLE_C)
        var clefToShow = staffMode == STAFF_DOUBLE_STAFF ? STAFF_BOTH : trebleRange >= bassRange ? STAFF_TREBLE : STAFF_BASE
        
        //set the drawing context to (0,0) at bottom left
        var ctx = UIGraphicsGetCurrentContext()
        var transform : CGAffineTransform = CGAffineTransformMakeTranslation(0.0, rect.height)
        transform = CGAffineTransformScale(transform, 1.0, -1.0) //switch origin to bottom left since images render upside down otherwise
        CGContextConcatCTM(ctx, transform)

        //draw staff lines
        var xPos : CGFloat = 10.0
        var middleCPos :CGFloat = 0
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.50)
        let key = SelectedKeys.getSelectedKey()
        if self.staffMode == STAFF_DOUBLE_STAFF {
            var staffCenter : CGFloat = rect.height / 4.0
            drawStaff(ctx, centerAt: staffCenter, margin: xPos, width: rect.width, staffType: STAFF_BASE, keySignature: key)
            staffCenter = (3 * rect.height) / 4.0
            drawStaff(ctx, centerAt: staffCenter, margin: xPos, width: rect.width, staffType: STAFF_TREBLE, keySignature: key)
        }
        else {
            let centerOfView : CGFloat = rect.height / 2.0
            drawStaff(ctx, centerAt: centerOfView, margin: xPos, width: rect.width, staffType: clefToShow, keySignature: key)
            middleCPos = 0 //clefToShow == STAFF_TREBLE ? (CGFloat(midLine - 6) * lineSpace) + centerOfView : (CGFloat(6 - midLine) * lineSpace) + centerOfView
        }
        
        CGContextStrokePath(ctx)
        
        // draw the clef(s)
        let numClefs = staffMode == STAFF_DOUBLE_STAFF ? 2 : 1
        let lineRange : (Int, Int) = clefToShow == STAFF_BOTH ? (-10, 10) : clefToShow == STAFF_TREBLE ? (2, 10) : (-10, -2)
        if staffMode == STAFF_DOUBLE_STAFF {
            clefToShow = STAFF_TREBLE //the first clef to draw
        }

        for clefNum : Int in 0...numClefs-1 {
            let clefHeight : CGFloat = clefToShow == STAFF_TREBLE ? 6 * lineSpace + lineSpace/1.5 : 4.5 * lineSpace
            let clefWidth = clefHeight / 2.0
            var clefImage : UIImage = clefToShow == STAFF_TREBLE ? UIImage(named: "treble_clef.png")! : UIImage(named: "bass_clef.png")!
            var clefOffset  : CGFloat = clefToShow == STAFF_TREBLE ? CGFloat(middleCPos - lineSpace/2) : CGFloat(middleCPos - lineSpace * 5)
            let clefRect = CGRect(x: xPos, y: clefOffset, width: clefWidth, height: clefHeight)
            //CGContextDrawImage(ctx, clefRect, clefImage.CGImage)
            
            //draw the key signature
            //let accidentals = key.getAccidentals(clefToShow)
            //let accidentalType = key.getAccidentals()

            /*for accidental in accidentals {
                let type = sharp ? ACCIDENTAL_SHARP : ACCIDENTAL_FLAT
                let acc = Accidental(midiOffset: accidental, type: type)
                self.renderObject(ctx, object: acc, key: key, xPos: xKeySigPos, middleCPos : middleCPos, lineRange: lineRange)
                xPos += 12
            }*/
            clefToShow += 1
        }
        xPos += 48
        
        // draw the notes in the voices
        for voice in self.staff!.voices {
            var x : CGFloat = xPos
            for object in voice.contents {
                if object is Chord {
                    let chord : Chord = object as! Chord
                    for note in chord.notes {
                        self.renderObject(ctx, object: note, key: key, xPos: x, middleCPos : middleCPos, lineRange: lineRange)
                    }
                }
                if object is Note {
                    let note : Note = object as! Note
                    self.renderObject(ctx, object: note, key: key, xPos: x, middleCPos : middleCPos, lineRange: lineRange)
                    
                }
                x += 48
            }
        }
    }
}
