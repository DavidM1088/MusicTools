import Foundation
import UIKit

class GraphView : UIView {
    private var notes : [Int] = []
    
    func setNotes(notes : [Int]) {
        self.notes = notes
    }
    
    override func drawRect(rect: CGRect) {
        if self.notes.count == 0 {
            return
        }
        let margin : CGFloat = 10.0
        var width = rect.size.width - 2*margin
        var height = rect.size.height
        var cHeight = height / 3.5
        var ctx = UIGraphicsGetCurrentContext()
        
        //axes
        let centerLine : CGFloat = rect.height / 2.0
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.25)
        CGContextMoveToPoint(ctx, margin, centerLine)
        CGContextAddLineToPoint(ctx, margin + width, centerLine)
        CGContextStrokePath(ctx)
        
        let baseFrequency : CGFloat = 2.0
        let baseNote = self.notes[0]
        var allZero : [CGFloat:Int] = [0:0]
        let colorBlue :[CGFloat] = [0.0, 100.0/255.0, 248.0/255.0, 1.0]
        let colorPurple :[CGFloat] = [128.0/255.0, 0.0, 1.0, 1.0]
        
        //plot the notes as sine curves with the note frequency
        //note > 1 frequency is shown relative to note[0] frequency (which is constant for all notes)
        for (var n = 0; n < self.notes.count; n++) {
            CGContextMoveToPoint(ctx, margin, height/2)
            let octaveOffset : CGFloat = CGFloat(self.notes[n] - baseNote) / 12.0
            let mult : CGFloat = octaveOffset + 1
            let frequency = pow(baseFrequency, mult)
            if n == 0 {
                CGContextSetStrokeColor(ctx, colorBlue)
            }
            else {
                CGContextSetStrokeColor(ctx, colorPurple)
            }
            for (var i = 0; i <= Int(width); i += 1 ) {
                var x : CGFloat = (CGFloat(i) * 2.0 * CGFloat(M_PI) * frequency) / CGFloat(width)
                var yVal = height/2 - (sin(x)  * cHeight)
                let xVal = CGFloat(i)
                if abs(yVal - centerLine) < 3 {
                    if allZero[xVal] == nil {
                        allZero[xVal] = 1
                    }
                    else {
                        allZero[xVal] = allZero[xVal]! + 1
                    }
                }
                CGContextAddLineToPoint(ctx, xVal + margin, yVal)
            }
            CGContextStrokePath(ctx)
        }
        
        //hilight the places where all notes join at the zero y value (showing the 'perfect' note ratios)
        for (xVal, count) in allZero {
            if count > 1 {
                CGContextSetFillColor(ctx, colorPurple)
                let sizes = [CGFloat(7.0) /*, CGFloat(3.0) */]
                for circSize in sizes {
                    let rect : CGRect = CGRect(origin: CGPoint(x: xVal - circSize/2 + margin, y: centerLine - circSize/2), size: CGSize(width: circSize, height: circSize))
                    CGContextAddEllipseInRect(ctx, rect)
                    //CGContextStrokePath(ctx)
                    CGContextFillPath(ctx)
                }
            }
        }
    }
    
}