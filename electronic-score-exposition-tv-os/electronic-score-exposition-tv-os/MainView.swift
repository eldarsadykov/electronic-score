//
//  MainView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 11.07.2022.
//

import AudioKit
import AVFoundation
import CSporthAudioKit
import Soundpipe
import SoundpipeAudioKit
import Sporth
import SporthAudioKit
import SwiftUI

let score = [[0, 0, 0.5, 0.5, 1, 0.75],
             [0, 0.5, 0.5, 1, 1, 0.75],
             [0, 0.5, 0.5, 0.5, 0.75, 0.25],
             [0.5, 0.5, 1, 1, 0.25, 0],
             [0, 0.5, 1, 0, 0.25, 0],
             [0, 0, 0.5, 0, 0.5, 0.25],
             [0.5, 1, 1, 1, 1, 0]]

let fps = 144

let totalTime: Double = 10

struct MainView: View {
    @StateObject var conductor = EventConductor()
    let counterMax = 1440
    let timer = Timer.publish(every: 1 / Double(fps), on: .main, in: .common).autoconnect()
    @State private var counter = -144
    @State private var playState = (0 ..< score.count).map { _ in false }
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // BACKGROUND
                Grid()
                    .stroke(lineWidth: 2)
                    .opacity(0.25)
                // CONTENT
                ForEach(0 ..< score.count, id: \.self) { i in
                    let scale = playState[i] ? 1.0 : 0
                    let incircle = incircleParams(score[i], width: geo.size.width, height: geo.size.height)
                    TriangleFramed(x: (score[i][1] - score[i][0]) / (score[i][2] - score[i][0]),
                                   y1: triangleCoordY(y: score[i][3], y1: score[i][3], y2: score[i][4], y3: score[i][5]),
                                   y2: triangleCoordY(y: score[i][4], y1: score[i][3], y2: score[i][4], y3: score[i][5]),
                                   y3: triangleCoordY(y: score[i][5], y1: score[i][3], y2: score[i][4], y3: score[i][5]))
                        .foregroundColor(.black)
                        .opacity(0.25 + scale * 0.25)
                        .frame(width: (score[i][2] - score[i][0]) * geo.size.width,
                               height: (max(score[i][3], score[i][4], score[i][5]) - min(score[i][3], score[i][4], score[i][5])) * geo.size.height)
                        .offset(x: triangleOffset(dim: geo.size.width,
                                                  dimMin: score[i][0],
                                                  dimMax: score[i][2]),
                                y: -triangleOffset(dim: geo.size.height,
                                                   dimMin: min(score[i][3], score[i][4], score[i][5]),
                                                   dimMax: max(score[i][3], score[i][4], score[i][5])))
                    TriangleFramed(x: (score[i][1] - score[i][0]) / (score[i][2] - score[i][0]),
                                   y1: triangleCoordY(y: score[i][3], y1: score[i][3], y2: score[i][4], y3: score[i][5]),
                                   y2: triangleCoordY(y: score[i][4], y1: score[i][3], y2: score[i][4], y3: score[i][5]),
                                   y3: triangleCoordY(y: score[i][5], y1: score[i][3], y2: score[i][4], y3: score[i][5]))
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .opacity(1)
                        .frame(width: (score[i][2] - score[i][0]) * geo.size.width,
                               height: (max(score[i][3], score[i][4], score[i][5]) - min(score[i][3], score[i][4], score[i][5])) * geo.size.height)
                        .offset(x: triangleOffset(dim: geo.size.width,
                                                  dimMin: score[i][0],
                                                  dimMax: score[i][2]),
                                y: -triangleOffset(dim: geo.size.height,
                                                   dimMin: min(score[i][3], score[i][4], score[i][5]),
                                                   dimMax: max(score[i][3], score[i][4], score[i][5])))

                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 5, dash: [10], dashPhase: 0))
                        .opacity(0.5 * (1 - scale))
                        .frame(width: incircle[2])
                        .offset(x: incircle[0], y: -incircle[1])
                    Circle()
                        .opacity(0.25 * scale)
                        .frame(width: incircle[2] * (scale * 0.95 + 0.05))
                        .offset(x: incircle[0], y: -incircle[1])
                }

                // FOREGROUND
                Playhead()
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .butt))
                    .foregroundColor(Color.green)
                    .opacity(0)
                    .onAppear {
                        self.conductor.start()
                        conductor.isRunning.toggle()
                    }
                    .onDisappear {
                        self.conductor.stop()
                    }
                    .onReceive(timer) { _ in
                        self.counter += 1
                        self.counter %= counterMax
                        for i in 0 ..< score.count {
                            let onTime = Int(score[i][0] * totalTime)
                            let offTime = Int(score[i][1] * totalTime)
                            let onDuration: Double = (score[i][1] - score[i][0]) * totalTime
                            let offDuration: Double = (score[i][2] - score[i][1]) * totalTime
                            if counter == Int(score[i][0] * Double(counterMax - 1)) {
                                conductor.triggeredEvents[i].parameter1 = 0
                            }
                            if counter == Int(score[i][0] * Double(counterMax - 1) + Double(counterMax - 10)) % counterMax {
                                conductor.triggeredEvents[i].parameter1 = 1
                            }
                            if onTime == offTime {
                                if counter == Int(score[i][1] * Double(counterMax - 1)) {
                                    playState[i] = true
                                    withAnimation(.easeInOut(duration: offDuration)) {
                                        playState[i] = false
                                    }
                                }
                            } else {
                                if counter == Int(score[i][0] * Double(counterMax - 1)) {
                                    withAnimation(.easeInOut(duration: onDuration)) {
                                        playState[i] = true
                                    }
                                }
                                if counter == Int(score[i][1] * Double(counterMax - 1)) {
                                    withAnimation(.easeInOut(duration: offDuration)) {
                                        playState[i] = false
                                    }
                                }
                            }
                        }
                    }
                    .offset(x: cursorOffsetCalc(counter, width: geo.size.width, max: counterMax))
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
