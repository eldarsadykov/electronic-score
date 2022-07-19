//
//  EventConductor.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 18.07.2022.
//

import AudioKit
import AVFoundation
import CSporthAudioKit
import Soundpipe
import SoundpipeAudioKit
import Sporth
import SporthAudioKit
import SwiftUI

class EventConductor: ObservableObject {
    let engine = AudioEngine()
    @Published var isRunning = false {
        didSet {
            if isRunning {
                for i in 0 ..< triggeredEvents.count {
                    triggeredEvents[i].start()
                }
            } else {
                for i in 0 ..< triggeredEvents.count {
                    triggeredEvents[i].stop()
                }
            }
        }
    }

//    let triggeredEvent: OperationGenerator
    let testFMArray: [FMOscillator]
    let triggeredEvents: [OperationGenerator]
    let sum: Mixer
    let reverb: CostelloReverb
    let dryWetMixer: DryWetMixer
    init() {
        func createSound() -> OperationGenerator {
            OperationGenerator { parameters in
//                let x = Operation.phasor(frequency: 1, phase: 0)
                let x = Operation.lineSegment(trigger: parameters[0],
                                              start: 0,
                                              end: 2, // excess phase to ensure that it reaches full 1
                                              duration: parameters[2] * 2 / 1000.0) // double duration to compensate double phase
                let midiNote = parameters[3] * 36 + 60
                let frequency = midiNote.midiNoteToFrequency()
                let ms = parameters[2]
                let aMin = 10.0 // minimum attack time ms
                let rMin = 10.0 // minimum release time ms
                let d21 = min(0.5, aMin / ms) // safe attack period
                let d32 = min(0.5, rMin / ms) // safe release period
                let x2 = min(1 - d32, max(d21, parameters[1]))

                let rampUp = x / x2
                let rampDown = (1 - x) / (1 - x2)

                let rampUpDown = min(rampUp, rampDown)
                let topClip = min(rampUpDown, 1.0)
                let bottomClip = max(topClip, 0.0)
                let amplitude = bottomClip * 1.0 / 5.0
                return Operation.fmOscillator(baseFrequency: frequency, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: amplitude, amplitude: amplitude * amplitude)
            }
        }
        func testFM(freq: AUValue, amp: AUValue) -> FMOscillator {
            FMOscillator(baseFrequency: freq, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: 1, amplitude: amp)
        }
//        let n = 50
        testFMArray = (0 ..< 50).map { i in
            testFM(freq: AUValue(i) * 55.0, amp: 1.0 / AUValue((i + 1) * 50))
        }
        triggeredEvents = (0 ..< score.count).map { _ in
            createSound()
        }
        for i in 0 ..< triggeredEvents.count {
            triggeredEvents[i].parameter1 = 1.0
            triggeredEvents[i].parameter2 = AUValue((score[i][1] - score[i][0]) / (score[i][2] - score[i][0]))
            triggeredEvents[i].parameter3 = AUValue((score[i][2] - score[i][0]) * totalTime * 1000.0)
            triggeredEvents[i].parameter4 = AUValue(incircleParams(score[i], width: 1, height: 1)[1])
        }
        sum = Mixer(triggeredEvents)
        reverb = CostelloReverb(sum, feedback: 0.8, cutoffFrequency: 10000)
        dryWetMixer = DryWetMixer(sum, reverb)
        dryWetMixer.balance = 0.25

//        mix.volume = 1.0 / AUValue(triggeredEvents.count)
        engine.output = dryWetMixer
//        triggeredEvent = OperationGenerator { parameters in
//            // parameters: 1-trigger, 2-relative x2, 3-duration ms, 4-incircle y
        ////            let x = Operation.phasor(frequency: 0.3)
//            let x = Operation.lineSegment(trigger: parameters[0],
//                                          start: 0,
//                                          end: 2, // excess phase to ensure that it reaches full 1
//                                          duration: parameters[2] * 2 / 1000.0) // double duration to compensate double phase
//            let midiNote = parameters[3] * 12 + 48
//            let frequency = midiNote.midiNoteToFrequency()
//            let ms = parameters[2]
//            let aMin = 10.0 // minimum attack time ms
//            let rMin = 10.0 // minimum release time ms
//            let d21 = min(0.5, aMin / ms) // safe attack period
//            let d32 = min(0.5, rMin / ms) // safe release period
//            let x2 = min(1 - d32, max(d21, parameters[1]))
//
//            let rampUp = x / x2
//            let rampDown = (1 - x) / (1 - x2)
//
//            let rampUpDown = min(rampUp, rampDown)
//            let topClip = min(rampUpDown, 1.0)
//            let bottomClip = max(topClip, 0.0)
//            let amplitude = bottomClip
        ////            return Operation.sineWave(frequency: frequency, amplitude: amplitude * amplitude)
//            return Operation.fmOscillator(baseFrequency: frequency, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: amplitude, amplitude: amplitude * amplitude)
//        }
//        triggeredEvent.parameter1 = 1.0 //   1.0             // trigger
//        triggeredEvent.parameter2 = AUValue((score[0][1] - score[0][0]) / (score[0][2] - score[0][0])) //   0              // relative x2
//        triggeredEvent.parameter3 = AUValue(5000) //   5000          // duration ms
//        triggeredEvent.parameter4 = 0 //   0            // incircle y
    }

    func start() {
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}
