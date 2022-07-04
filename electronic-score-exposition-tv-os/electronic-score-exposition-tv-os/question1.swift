//
//  question1.swift
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
    let engine = AudioEngine()
    @Published var isRunning = false {
        didSet {
            isRunning ? mainPhasor.start() : mainPhasor.stop()
        }
    }

    init() {
        mainPhasor = OperationGenerator { _ in
            Operation.phasor(frequency: 1 / 10)
        }
    }
}


