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
    let mainPhasor: OperationGenerator
//    let impulse: OperationGenerator
    let engine = AudioEngine()
    @Published var isRunning = false {
        didSet {
            isRunning ? mainPhasor.start() : mainPhasor.stop()
        }
    }

    init() {
        mainPhasor = OperationGenerator { _ in
            let phasor = Operation.phasor(frequency: 1)
            let sine = Operation.sineWave(frequency: phasor * 220 + 220, amplitude: min(phasor, 1 - phasor)
            )
            return sine
        }
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
    @StateObject var pConductor = PhasorConductor()
    var body: some View {
        Button("Reset") {
        }
        .onAppear {
            self.pConductor.start()
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
