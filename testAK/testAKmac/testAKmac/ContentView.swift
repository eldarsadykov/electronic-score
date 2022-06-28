import AudioKit
import AudioKitUI
import SporthAudioKit
import SwiftUI

class SegmentOperationModifiedConductor: ObservableObject {
    // let customTable = Table
    let engine = AudioEngine()
    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator { parameters in
   
        let updateRate = parameters[0]
        let x = Operation.lineSegment(trigger: Operation.metronome(frequency: updateRate),
                                      start: 0,
                                      end: 1,
                                      duration: 0.5/updateRate)
        let frequency = 220.0
        let x1 = 0.1
        let y1 = 0.0
        let x2 = 0.2
        let y2 = 1.0
        let x3 = 0.9
        let y3 = 0.0
        let rampUp = ((x - x1) * (y2 - y1) / max(x2 - x1, 0.05)) + y1
        let rampDown = ((x - x2) * (y3 - y2) / max(x3 - x2, 0.05)) + y2
        let amplitude = max(min(min(rampUp, rampDown), 1), 0)
        return Operation.fmOscillator(baseFrequency: frequency, carrierMultiplier: 1, modulatingMultiplier: 1, modulationIndex: amplitude, amplitude:amplitude)
    }

    init() {
        generator.parameter1 = 8
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

struct SegmentOperationModifiedView: View {
    @StateObject var conductor = SegmentOperationModifiedConductor()

    var body: some View {
        VStack(spacing: 20) {
            Text("Creating segments that vary parameters in operations linearly or exponentially over a certain duration")
            Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
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
