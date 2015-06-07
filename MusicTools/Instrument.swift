import AVFoundation
import AudioUnit

class Instrument {
    //var sampler: AVAudioUnitSampler
    let sampler = AVAudioUnitSampler()
    
    init(midiPresetId : Int) {
        AudioEngine.sharedInstance.attachSampler(self.sampler, midiInstrument: midiPresetId)
    }
    
    deinit  {
        AudioEngine.sharedInstance.detachSampler(self.sampler)
        Logger.log("instument deattached")
    }
    
    func playNote(note:Int) {
        sampler.startNote(UInt8(note), withVelocity: 80, onChannel: 0)
    }
    
    func stopNote(note:Int) {
        sampler.stopNote(UInt8(note), onChannel: 0)
    }
    
    func play(object:StaffObject) {
        if object is Note {
            let note = object as! Note
            playNote(note.noteValue)
        }
        if object is Chord {
            let chord = object as! Chord
            for note in chord.notes {
                playNote(note.noteValue)
            }
        }
        if object is Rest {

        }
    }
    
    func stop(object: StaffObject) {
        if object is Note {
            let note = object as! Note
            stopNote(note.noteValue)
        }
        if object is Chord {
            let chord = object as! Chord
            for note in chord.notes {
                stopNote(note.noteValue)
            }
        }
        if object is Rest {
            
        }
    }
}