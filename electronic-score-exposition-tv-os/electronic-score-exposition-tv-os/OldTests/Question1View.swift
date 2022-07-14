//
//  Question1View.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 03.07.2022.
//

import AudioKit
import AVFoundation
import CSporthAudioKit
import Soundpipe
import SoundpipeAudioKit
import Sporth
import SporthAudioKit
import SwiftUI

class PhasorConductor: ObservableObject {
    let seconds = 1
    var startDate = Date().timeIntervalSinceReferenceDate
    let mainPhasor: OperationGenerator
//    let impulse: OperationGenerator
    let engine = AudioEngine()
    @Published var isRunning = false {
        didSet {
            isRunning ? mainPhasor.start() : mainPhasor.stop()
        }
    }

    init() {
        mainPhasor = OperationGenerator { parameters in
            let phasor = Operation.phasor(frequency: 1.0 / parameters[0])
            let sine = Operation.sineWave(frequency: phasor * 220 + 220, amplitude: min(phasor, 1 - phasor)
            )
            return sine
        }
        mainPhasor.parameter1 = AUValue(seconds)
        engine.output = mainPhasor
        mainPhasor.start()
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

struct Question1View: View {
    let timer = Timer.publish(every: 1 / 1000, on: .main, in: .common).autoconnect()

    @State private var counter = 0
    @StateObject var pConductor = PhasorConductor()
    
    var body: some View {
        GeometryReader { geo in

            Rectangle()
                .frame(width: 8)
                .onReceive(timer) { _ in
                    counter += 1
                    counter %= Int(geo.size.width)
                }
                .offset(x: CGFloat(counter))
                .foregroundColor(.red)
            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate - pConductor.startDate
//                let divider: Double = 20
                let offsetX = now.remainder(dividingBy: 1) / 1.0 * geo.size.width + (geo.size.width / 2.0)
//                let offsetX = (1720 * now).truncatingRemainder(dividingBy: 1.0)
//                Spacer()

                Rectangle()
                    .frame(width: 8)
                    .offset(x: offsetX)
//                Button("now") {
//                    pConductor.startDate = Date().timeIntervalSinceReferenceDate
//                }
            }
//            .foregroundColor(Color.red)
        }
//        .background(Color.red)

//            .frame(width: $position)
//        Button("Reset") {
//        }
        .onAppear {
            self.pConductor.start()
            self.pConductor.startDate = Date().timeIntervalSinceReferenceDate
        }
        .onDisappear {
            self.pConductor.stop()
        }
    }
}

struct Question1View_Previews: PreviewProvider {
    static var previews: some View {
        Question1View()
    }
}
