//
//  ContentView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 20.06.2022.
//

import AudioKit
import AVFoundation
// import DunneAudioKit
import Soundpipe
import SoundpipeAudioKit
import Sporth
import SwiftUI

var engine = AudioEngine()

class OscillatorObject {
    var osc = FMOscillator()

    init() {
        engine.output = osc
    }

    func start() {
        osc.baseFrequency = 220
        osc.amplitude = 0
        //        osc.$amplitude.ramp(to: 0.5, duration: 2)

        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
        osc.start()
    }

    func stop() {
        osc.stop()
        engine.stop()
    }

    func listen() {
        osc.$amplitude.ramp(to: 0.1, duration: 2)
    }

    func rampUp() {
        //        osc.$baseFrequency.ramp(to: 220, duration: 2)
        //        osc.$amplitude.ramp(to: 0.5, duration: 2)
        osc.$modulationIndex.ramp(to: 2, duration: 2)
    }

    func rampDown() {
        //        osc.$baseFrequency.ramp(to: 220, duration: 2)
        //        osc.$amplitude.ramp(to: 0.5, duration: 2)
        osc.$modulationIndex.ramp(to: 1, duration: 2)
    }

    func on() {
        osc.$amplitude.ramp(to: 0.1, duration: 2)
    }

    func off() {
        osc.$amplitude.ramp(to: 0, duration: 2)
    }
}


struct PlayHead: View {
    @State var color = Color.red
    @State var atEnd = false
    let widthX: Double
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundColor(color)
                .offset(x: geometry.size.width * (atEnd ? 1 : 0))
                .frame(width: widthX)
                .opacity(0.5)
                .onAppear {
                    play()
//                    recolor()
                }
        }
    }

    func recolor() {
        color = Color.green
    }

    func play() {
        if atEnd {
            atEnd.toggle()
        } else {
            withAnimation(.linear(duration: 10)) {
                atEnd.toggle()
            }
        }
    }
}

struct ContentView: View {
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

    struct Triangle: InsettableShape {
        let x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double
        var insetAmount = 0.0
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let minX = rect.minX + insetAmount
            let minY = rect.minY + insetAmount
            let maxX = rect.maxX - insetAmount * 2
            let maxY = rect.maxY - insetAmount * 2
            path.move(to: CGPoint(x: minX + x1 * maxX / 12, y: minY + (y1 * maxY / 12.0)))
            path.addLine(to: CGPoint(x: minX + x2 * maxX / 12, y: minY + (y2 * maxY / 12.0)))
            path.addLine(to: CGPoint(x: minX + x3 * maxX / 12, y: minY + (y3 * maxY / 12.0)))
            path.closeSubpath()
            return path
        }

        func inset(by amount: CGFloat) -> some InsettableShape {
            var arc = self
            arc.insetAmount += amount
            return arc
        }
    }

    var oscobj = OscillatorObject()
    let baseWidth = 2.0
    var time: Double = 0
    var body: some View {
        GeometryReader { _ in
            ScrollView(.horizontal) {
                VStack {
                    ZStack {
                        Grid()
                            .stroke(Color.black, lineWidth: baseWidth)
                            .opacity(0.1)
                        Triangle(x1: 0, y1: 0, x2: 6, y2: 12, x3: 12, y3: 0)
                            .strokeBorder(Color.black,
                                          style: StrokeStyle(
                                              lineWidth: baseWidth * 2,
                                              lineJoin: .round
                                          ))
                            .onAppear {
                                oscobj.start()
                            }
                            .onDisappear {
                                oscobj.stop()
                            }
                            .onTapGesture {
                                oscobj.listen()
                            }

                        let playHead = PlayHead(widthX: baseWidth * 4)
                        playHead
                        Button("Play") {
                            playHead.recolor()
                        }
                    }

                    .foregroundColor(Color.black)
                    HStack {
                        Button("Up") {
                            oscobj.rampUp()
                        }

                        .padding()
                        .background(Color.green)
                        Button("Down") {
                            oscobj.rampDown()
                        }.padding()
                        Button("On") {
                            oscobj.on()
                        }.padding()
                        Button("Off") {
                            oscobj.off()
                        }.padding()
                    }
                }
                .background(Color.white)
                .frame(width: 2000)

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
