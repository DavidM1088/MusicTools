import AVFoundation
import AudioUnit

class MIDISampler : NSObject {
    var engine:AVAudioEngine!
    var playerNode:AVAudioPlayerNode!
    var mixer:AVAudioMixerNode!
    var sampler0:AVAudioUnitSampler!
    var sampler1:AVAudioUnitSampler!
    /// soundbanks are either dls or sf2. see http://www.sf2midi.com/
    var soundbank:NSURL!
    let melodicBank:UInt8 = UInt8(kAUSampler_DefaultMelodicBankMSB)
    /// general midi number for marimba
    let gmMarimba:UInt8 = 12
    let gmHarpsichord:UInt8 = 6
    let gmGrand:UInt8 = 24
    
    override init() {
        super.init()
        initAudioEngine()
    }
    
    func initAudioEngine () {
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        engine.attachNode(playerNode)
        mixer = engine.mainMixerNode
        
        sampler0 = AVAudioUnitSampler()
        sampler1 = AVAudioUnitSampler()
        engine.attachNode(sampler0)
        var mixerOn = 1
        if mixerOn == 1 {
            engine.connect(sampler0, to: mixer, format: nil)
            engine.attachNode(sampler1)
            engine.connect(sampler1, to: mixer, format: nil)
        }
        else {
            engine.connect(sampler0, to: engine.outputNode, format: nil)
        }
        
        soundbank = NSBundle.mainBundle().URLForResource("GeneralUser_GS_MuseScore", withExtension: "sf2")
        //println("-----> soundbank \(soundbank)")
            
        var error:NSError?
        if !engine.startAndReturnError(&error) {
            println("error couldn't start engine")
            if let e = error {
                println("error \(e.localizedDescription)")
            }
        }
        // cello=42 marimba=12, piano=0
        loadInstr(0, instr: 12)
        if mixerOn == 1 {
            loadInstr(1, instr: 42)
        }
    }
    
    func loadInstr(samp:Int, instr:Int) {
        var error:NSError?
        if samp == 0 {
            if !sampler0.loadSoundBankInstrumentAtURL(soundbank, program: UInt8(instr),
                bankMSB: melodicBank, bankLSB: 0, error: &error) {
                    println("could not load soundbank")
            }
        }
        if samp == 1 {
            if !sampler1.loadSoundBankInstrumentAtURL(soundbank, program: UInt8(instr),
                bankMSB: melodicBank, bankLSB: 0, error: &error) {
                    println("could not load soundbank")
            }
        }
        if let e = error {
            println("error \(e.localizedDescription)")
        }
    }

    func test() {
        //https://developer.apple.com/library/ios/technotes/tn2283/_index.html
        //cello= 42
        loadInstr(0, instr: 0) //cello
        //loadInstr(1, instr: 12) //marimba
        loadInstr(1, instr: 0) //piano

        self.sampler0.startNote(UInt8(64), withVelocity: 64, onChannel: 0)
        sleep(1)
        self.sampler1.startNote(UInt8(68), withVelocity: 64, onChannel: 0)
        sleep(3)
        //sampler.startNote(76)
        //sleep(4)
        println("-----done ----")
    }

}