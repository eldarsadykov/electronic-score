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
    let triangle = Triangle(x1: 0, y1: 0.5, x2: 0.0, y2: 1, x3: 1, y3: 0)
    let engine = AudioEngine()
    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator { parameters in

        let ms = parameters[0] // total score time ms
        let x = Operation.phasor(frequency: 1000 / ms, phase: 0.0)
        let frequency = 220.0
        let aMin = 5.0 // minimum attack time ms
        let rMin = 10.0 // minimum release time ms

        let x01 = parameters[1] // note start time
        let x02 = parameters[2] // note peak time
        let x03 = parameters[3] // note end time

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
        
        return Operation.fmOscillator(baseFrequency: frequency, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: amplitude*amplitude, amplitude: amplitude*amplitude)
    }

    init() {
        generator.parameter1 = 1000
        
        generator.parameter2 = AUValue(triangle.x1)
        generator.parameter3 = AUValue(triangle.x2)
        generator.parameter4 = AUValue(triangle.x3)
        
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

struct Triangle: InsettableShape {
    let x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double
    var insetAmount = 0.0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let minX = rect.minX + insetAmount
        let minY = rect.minY + insetAmount
        let maxX = rect.maxX - insetAmount * 2
        let maxY = rect.maxY - insetAmount * 2
        path.move(to: CGPoint(x: minX + x1 * maxX, y: minY + y1 * maxY))
        path.addLine(to: CGPoint(x: minX + x2 * maxX, y: minY + y2 * maxY))
        path.addLine(to: CGPoint(x: minX + x3 * maxX, y: minY + y3 * maxY))
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var tri = self
        tri.insetAmount += amount
        return tri
    }
}

struct SwiftUIView: View {
    @StateObject var conductor = BasicEventConductor()

    var body: some View {
        VStack(spacing: 20) {
            conductor.triangle
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
