import AVFoundation
import UIKit

class Voice {
    var contents = [StaffObject]()
    var instrument : Instrument
    var beatNum = 0
    var lastSound : StaffObject?
    
    init(instr: Instrument) {
        instrument = instr
    }
    
    func startPlay() {
        self.beatNum = 0
        self.lastSound = nil
    }
    
    func add(object: StaffObject) {
        contents.append(object)
    }
    
    func addObjects(objects: [StaffObject]) {
        for object in objects {
            contents.append(object)
        }
    }
    
    func isFinishedPlaying() -> Bool {
        return self.beatNum >= self.contents.count && self.lastSound == nil    }
    
    func play() {
        //println("beat \(self.beatNum)")
        if self.lastSound != nil {
            //for note in self.lastSound!.notes {
            //    instrument.stopNote(note)
            //}
            instrument.stop(lastSound!)
            self.lastSound = nil
        }
        if self.beatNum >= self.contents.count {
            return
        }
        //for note in contents[self.beatNum].notes {
        //    instrument.playNote(note)
        //}
        instrument.play(contents[beatNum])
        self.lastSound = self.contents[self.beatNum]
        self.beatNum += 1
    }
}

var staffNo = 0

class Staff {
    var voices = [Voice]()
    var beatNum = 0
    var timer = NSTimer()
    var tempo : Double = 0.0
    var id :Int
    var stopForced : Bool
    
    init () {
        id = staffNo
        staffNo += 1
        stopForced = false
    }
    
    deinit {
        Logger.log("Staff deinit")
    }
    
    func setTempo(tempo : Double) {
        self.tempo = tempo
    }
    
    func addVoice(voice : Voice) {
        voices.append((voice))
    }
    
    func forceStop() {
        //self.timer.invalidate()
        stopForced = true
    }
    
    @objc func beat() {
        //println("====> Staff beat before play \(beatNum)")
        var done : Bool = true
        for voice in voices {
            if !voice.isFinishedPlaying() {
                voice.play()
                done = false
            }
        }
        beatNum += 1
        if done || stopForced {
            //self.timer.invalidate()
        }
        else {
            //println("====> Staff beat start timer \(beatNum)")
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.tempo, target: self, selector: Selector("beat"), userInfo: nil, repeats: false)
            //println("====> Staff beat after timer \(beatNum)")
        }
    }
    
    func play() {
        beatNum = 0
        for voice in voices {
            voice.startPlay()
        }
        self.beat()
    }
    

    
}