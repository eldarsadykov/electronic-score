//
//  MainView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 11.07.2022.
//

import SwiftUI

let fps = 144

struct MainView: View {
    let counterMax = 1440
    let totalTime: Double = 10
    let timer = Timer.publish(every: 1 / Double(fps), on: .main, in: .common).autoconnect()
    @State private var counter = -100
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
//                    let onDur: Double
                    let scale = playState[i] ? 1.0 : 0
                    let incircle = incircleParams(score[i], width: geo.size.width, height: geo.size.height)
                    TriangleFramed(x: (score[i][1] - score[i][0]) / (score[i][2] - score[i][0]),
                                   y1: triangleCoordY(y: score[i][3], y1: score[i][3], y2: score[i][4], y3: score[i][5]),
                                   y2: triangleCoordY(y: score[i][4], y1: score[i][3], y2: score[i][4], y3: score[i][5]),
                                   y3: triangleCoordY(y: score[i][5], y1: score[i][3], y2: score[i][4], y3: score[i][5]))
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
//                        .opacity(0.5)
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
                        .opacity(0.25 * (1 - scale))
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
                    .opacity(0.5)
                    .onReceive(timer) { _ in
                        self.counter += 1
                        self.counter %= counterMax
                        for i in 0 ..< score.count {
                            let onTime = Int(score[i][0] * totalTime)
                            let offTime = Int(score[i][1] * totalTime)
                            let onDuration: Double = (score[i][1] - score[i][0]) * totalTime
                            let offDuration: Double = (score[i][2] - score[i][1]) * totalTime
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
