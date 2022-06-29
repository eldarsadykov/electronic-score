//
//  SwiftUIView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 29.06.2022.
//

import AudioKit
import AVFoundation
import CSporthAudioKit
import Soundpipe
import SoundpipeAudioKit
import Sporth
import SporthAudioKit
import SwiftUI

class BasicEventConductor: ObservableObject {
    let engine = AudioEngine()
    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator { parameters in

        let updateRate = parameters[0]
//        let x = Operation.lineSegment(trigger: Operation.metronome(frequency: updateRate), start: 0.0, end: 1.0, duration: 1 / updateRate)
        let x = Operation.phasor(frequency: updateRate, phase: 0.0)
        let frequency = 220.0

        let ms = 1000.0 / updateRate // total score time ms
        let aMin = 5.0 // minimum attack time ms
        let rMin = 20.0 // minimum release time ms

        let x01 = 0.0 // note start time
        let x02 = 1.0 // note peak time
        let x03 = 1.0 // note end time

        let d21 = min(0.5, aMin / ms) // safe attack period
        let d32 = min(0.5, rMin / ms) // safe release period
        let d31 = d21 + d32 // safeNoteLength

        let x1 = max(0.0, min(x01, 1.0 - d31)) // protect start
        let x3 = min(1.0, max(x03, x1 + d31)) // protect end
        let x2 = x1 + min(x3 - d32, max(x02 - x1, d21)) // protect middle

        let rampUp = (x - x1) / (x2 - x1)
        let rampDown = 1 - (x - x2) / (x3 - x2)

        let rampUpDown = min(rampUp, rampDown)
        let topClip = min(rampUpDown, 1.0)
        let bottomClip = max(topClip, 0.0)
        let amplitude = bottomClip
//        return Operation.triangle(frequency: frequency, amplitude: amplitude, phase: 0.0)
        return Operation.fmOscillator(baseFrequency: frequency, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: amplitude, amplitude: amplitude)
    }

    init() {
        generator.parameter1 = 1
        engine.output = generator
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

struct SwiftUIView: View {
    @StateObject var conductor = BasicEventConductor()

    var body: some View {
        VStack(spacing: 20) {
            Text("Creating segments that vary parameters in operations linearly or exponentially over a certain duration")
            Button(conductor.isRunning ? "Stop" : "Start") {
                conductor.isRunning.toggle()
            }
        }
        .padding()
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
