//
//  TriangleEnvelope.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 01.07.2022.
//
//
// import AudioKit
// import AVFoundation
// import CSporthAudioKit
// import Soundpipe
// import SoundpipeAudioKit
// import Sporth
// import SporthAudioKit
// import SwiftUI
//

import AudioKit
import SporthAudioKit

// import AudioKitEX

//func triangleEnvelope(_ input: Node) {
//    let sound1 = OperationEffect(input, operation: { parameters in
//        let ms = parameters[0]
//        let x = input
//        let midiNote = parameters[4] * 12 + 48
//        let frequency = midiNote.midiNoteToFrequency()
//        let aMin = 5.0 // minimum attack time ms
//        let rMin = 5.0 // minimum release time ms
//
//        let x01 = parameters[1] // note start time
//        let x02 = parameters[2] // note peak time
//        let x03 = parameters[3] // note end time
//
//        let d21 = min(0.5, aMin / ms) // safe attack period
//        let d32 = min(0.5, rMin / ms) // safe release period
//        let d31 = d21 + d32 // safeNoteLength
//
//        let x1 = max(0.0, min(x01, 1.0 - d31)) // protect start
//        let x3 = min(1.0, max(x03, x1 + d31)) // protect end
//        let x2 = x1 + min(x3 - d32, max(x02 - x1, d21)) // protect middle
//
//        let rampUp = (x - x1) / (x2 - x1)
//        let rampDown = 1 - (x - x2) / (x3 - x2)
//
//        let rampUpDown = min(rampUp, rampDown)
//        let topClip = min(rampUpDown, 1.0)
//        let bottomClip = max(topClip, 0.0)
//        let amplitude = bottomClip * 0.25
//
//        return Operation.fmOscillator(baseFrequency: frequency, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: amplitude, amplitude: amplitude)
//    })
//}
