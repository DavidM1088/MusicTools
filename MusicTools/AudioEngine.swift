import AVFoundation
import AudioUnit

class AudioEngine : NSObject {
    var engine:AVAudioEngine!
    var playerNode:AVAudioPlayerNode!
    var mixer:AVAudioMixerNode!
    /// soundbanks are either dls or sf2. see http://www.sf2midi.com/
    var soundbank:NSURL!
    let melodicBank:UInt8 = UInt8(kAUSampler_DefaultMelodicBankMSB)
    var instance : AudioEngine?
    var instruments = SelectedInstruments.sharedInstance
    var samplerCount = 0
    
    class var sharedInstance: AudioEngine {
        struct Singleton {
            static let instance = AudioEngine()
        }
        return Singleton.instance
    }
    
    func attachSampler(sampler : AVAudioUnitSampler, midiInstrument : Int) {
        engine.attachNode(sampler)
        engine.connect(sampler, to: mixer, format: nil)
        var error:NSError?
        if !sampler.loadSoundBankInstrumentAtURL(soundbank, program: UInt8(midiInstrument),
            bankMSB: melodicBank, bankLSB: 0, error: &error) {
                println("could not load soundbank for instrument \(midiInstrument)")
        }
        samplerCount += 1
        Logger.log("audio samplers - attached count:\(self.samplerCount)")
    }
    
    func detachSampler(sampler : AVAudioUnitSampler) {
        engine.disconnectNodeInput(sampler)
        engine.detachNode(sampler)
        samplerCount -= 1
        Logger.log("audio samplers - detached count:\(self.samplerCount)")
    }

    private override init() {
        super.init()
        initAudioEngine()
    }
    
    private func initAudioEngine () {
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        engine.attachNode(playerNode)
        mixer = engine.mainMixerNode
        
        //sampler0 = AVAudioUnitSampler()
        //sampler1 = AVAudioUnitSampler()
        //engine.attachNode(sampler0)
        
        //engine.connect(sampler0, to: mixer, format: nil)
        //engine.attachNode(sampler1)
        //engine.connect(sampler1, to: mixer, format: nil)
        
        soundbank = NSBundle.mainBundle().URLForResource("GeneralUser_GS_MuseScore", withExtension: "sf2")
        //println("-----> soundbank \(soundbank)")
            
        var error:NSError?
        if !engine.startAndReturnError(&error) {
            println("error couldn't start engine")
            if let e = error {
                println("error \(e.localizedDescription)")
            }
        }
    }
    
    func test() {
        //https://developer.apple.com/library/ios/technotes/tn2283/_index.html
        //cello= 42
        //loadInstrument(0, instr: 0) //cello
        //loadInstr(1, instr: 12) //marimba
        //loadInstrument(1, instr: 0) //piano

        //self.sampler0.startNote(UInt8(64), withVelocity: 64, onChannel: 0)
        sleep(1)
        //self.sampler1.startNote(UInt8(68), withVelocity: 64, onChannel: 0)
        sleep(3)
        //sampler.startNote(76)
        //sleep(4)
        println("-----done ----")
    }

}