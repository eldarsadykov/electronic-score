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
    var cursor: Int
    var startDate = Date().timeIntervalSinceReferenceDate
    let ms: Int = 2000
    let triangle1 = Triangle(x1: 0.0, y1: 0.25, x2: 0.0, y2: 1, x3: 1, y3: 0)
    let triangle2 = Triangle(x1: 0.0, y1: 1, x2: 0.5, y2: 0, x3: 1, y3: 0)

    let engine = AudioEngine()
    @Published var isRunning = false
//    {
//        didSet {
//            isRunning ? testEvent.start() : testEvent.stop()
//        }
//    }

    let mainPhasor: OperationGenerator
    let sound1: OperationEffect
    let sound2: OperationEffect
    let sum: Mixer
    let reverb: CostelloReverb
    let dryWetMixer: DryWetMixer
    let testEvent: OperationGenerator

    init() {
        testEvent = OperationGenerator { parameters in
            let line = Operation.lineSegment(trigger: parameters[0],
                                             start: 0.0,
                                             end: 1.0,
                                             duration: 0.5 * parameters[1] / 1000.0)
            return Operation.fmOscillator(baseFrequency: 220, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: 1, amplitude: min(line, 1 - line))
        }
        mainPhasor = OperationGenerator { parameters in
            let ms = parameters[0] // total score time ms
            return Operation.phasor(frequency: 1000 / ms, phase: 0.0)
        }

        func createSound(input: OperationGenerator) -> OperationEffect {
            OperationEffect(input) { input, parameters in
                let ms = parameters[0]
                let x = input / 2
                let midiNote = parameters[4] * 12 + 48
                let frequency = midiNote.midiNoteToFrequency()
                let aMin = 10.0 // minimum attack time ms
                let rMin = 10.0 // minimum release time ms

                let x01 = parameters[1] // note start time
                let x02 = parameters[2] // note peak time
                let x03 = parameters[3] // note end time

                let d21 = min(0.5, aMin / ms) // safe attack period
                let d32 = min(0.5, rMin / ms) // safe release period
                let d31 = d21 + d32 // safeNoteLength

                let x1 = max(0.0, min(x01, 1.0 - d31)) // protect start
                let x3 = min(1.0, max(x03, x1 + d31)) // protect end
                let x2 = x1 + min(x3 - x1 - d32, max(x02 - x1, d21)) // protect middle

                let rampUp = (x - x1) / (x2 - x1)
                let rampDown = 1 - (x - x2) / (x3 - x2)

                let rampUpDown = min(rampUp, rampDown)
                let topClip = min(rampUpDown, 1.0)
                let bottomClip = max(topClip, 0.0)
                let amplitude = bottomClip * 0.25

                return Operation.fmOscillator(baseFrequency: frequency, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: amplitude, amplitude: amplitude * amplitude)
            }
        }
        cursor = 0
        sound1 = createSound(input: mainPhasor)
        sound2 = createSound(input: mainPhasor)
        testEvent.parameter1 = 1.0
        testEvent.parameter2 = AUValue(ms)
        mainPhasor.parameter1 = AUValue(ms)

        sound1.parameter1 = AUValue(ms)
        sound1.parameter2 = AUValue(triangle1.x1)
        sound1.parameter3 = AUValue(triangle1.x2)
        sound1.parameter4 = AUValue(triangle1.x3)
        sound1.parameter5 = AUValue(triangle1.y1)

        sound2.parameter1 = AUValue(ms)
        sound2.parameter2 = AUValue(triangle2.x1)
        sound2.parameter3 = AUValue(triangle2.x2)
        sound2.parameter4 = AUValue(triangle2.x3)
        sound2.parameter5 = AUValue(triangle2.y1)

        sum = Mixer(sound1, sound2)
        reverb = CostelloReverb(sum, feedback: 0.8, cutoffFrequency: 10000)
        dryWetMixer = DryWetMixer(sum, reverb)
        dryWetMixer.balance = 0.25
        engine.output = testEvent
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

struct Playhead: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

struct Triangle: InsettableShape {
    let x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double
    var insetAmount = 0.0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let minX = rect.minX + insetAmount
//        let minY = rect.minY + insetAmount
        let maxX = rect.maxX - insetAmount * 2
        let maxY = rect.maxY - insetAmount * 2
        path.move(to: CGPoint(x: minX + x1 * maxX, y: maxY - y1 * maxY))
        path.addLine(to: CGPoint(x: minX + x2 * maxX, y: maxY - y2 * maxY))
        path.addLine(to: CGPoint(x: minX + x3 * maxX, y: maxY - y3 * maxY))
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var tri = self
        tri.insetAmount += amount
        return tri
    }
}

struct Grid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        for i in 0 ... 12 {
            path.move(to: CGPoint(x: maxX * CGFloat(i) / 12, y: minY))
            path.addLine(to: CGPoint(x: maxX * CGFloat(i) / 12, y: maxY))
            path.move(to: CGPoint(x: minX, y: maxY * CGFloat(i) / 12))
            path.addLine(to: CGPoint(x: maxX, y: maxY * CGFloat(i) / 12))
        }
        return path
    }
}

func offsetCalc(_ count: Int, width: CGFloat, max: Int) -> CGFloat {
    width * CGFloat(count) / CGFloat(max)
}

struct SwiftUIView: View {
    @State var lineSeg = true
    let timer = Timer.publish(every: 1 / 1000, on: .main, in: .common).autoconnect()
    @StateObject var conductor = BasicEventConductor()
    @State private var counter = 0
    var body: some View {
        Button("Toggle: \(lineSeg ? "On" : "Off")") {
            lineSeg.toggle()
            conductor.testEvent.parameter1 = lineSeg ? 1.0 : 0.0
        }

        HStack {
            GeometryReader { geometry in
                Playhead()
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .butt))
                    .foregroundColor(Color.red)
                    .opacity(0.5)
                    .onReceive(timer) { _ in
                        self.counter += 1
                        self.counter %= Int(conductor.ms)
                        if counter == 500 {
                            lineSeg = false
                            conductor.testEvent.start()
                            conductor.testEvent.parameter1 = lineSeg ? 1.0 : 0.0
                        }
                        if counter == 1500 {
                            lineSeg = true
                            conductor.testEvent.parameter1 = lineSeg ? 1.0 : 0.0
                            conductor.testEvent.stop()
                        }
                    }
                    .offset(x: offsetCalc(self.counter, width: geometry.size.width, max: conductor.ms))
                ZStack {
                    Grid()
                        .stroke(lineWidth: 2)
                        .opacity(0.25)
                    conductor.triangle1
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

                    conductor.triangle2
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                }
                .onAppear {
                    conductor.isRunning.toggle()
                    conductor.startDate = Date().timeIntervalSinceReferenceDate
                }
            }
            .onAppear {
                self.conductor.start()
            }
            .onDisappear {
                self.conductor.stop()
            }
        }
    }
}
