//
//  ContentView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 20.06.2022.
//


import SwiftUI
import AudioKit
//import DunneAudioKit
import Soundpipe
import Sporth
import AVFoundation
import SoundpipeAudioKit

class OscillatorObject {
    var engine = AudioEngine()
    
    var osc = FMOscillator()
    
    init() {
        engine.output = osc
        
    }
    func start(){
        
        osc.baseFrequency = 220;
        osc.amplitude = 0;
        //        osc.$amplitude.ramp(to: 0.5, duration: 2)
        
        
        do {
            
            try engine.start()
        } catch let err {
            Log(err)
        }
        osc.start()
    }
    func stop (){
        osc.stop()
        engine.stop()
    }
    func rampUp(){
        //        osc.$baseFrequency.ramp(to: 220, duration: 2)
        //        osc.$amplitude.ramp(to: 0.5, duration: 2)
        osc.$modulationIndex.ramp(to: 2, duration: 2)
    }
    func rampDown(){
        //        osc.$baseFrequency.ramp(to: 220, duration: 2)
        //        osc.$amplitude.ramp(to: 0.5, duration: 2)
        osc.$modulationIndex.ramp(to: 1, duration: 2)
    }
    func on(){
        osc.$amplitude.ramp(to: 0.1, duration: 2)
    }
    func off(){
        osc.$amplitude.ramp(to: 0, duration: 2)
    }
}

struct ContentView: View {
    struct Triangle: InsettableShape {
        var insetAmount = 0.0
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let minX = rect.minX+insetAmount
            let minY = rect.minY+insetAmount
            let maxX = rect.maxX-insetAmount
            let maxY = rect.maxY-insetAmount
            path.move(to: CGPoint(x: (minX+0.5*maxX), y: minY))
            path.addLine(to: CGPoint(x: minX, y: maxY*0.5))
            path.addLine(to: CGPoint(x: maxX, y: maxY))
//            path.addLine(to: CGPoint(x: (minX+0.5*maxX), y: minY))
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
    var body: some View {
        VStack{
            GeometryReader {geometry in
                ZStack{
                    Rectangle()
                        .strokeBorder(Color.gray, lineWidth: baseWidth)
                        .opacity(0.5)

                    Triangle()
                        .strokeBorder(Color.white,
                                style: StrokeStyle(
                                    lineWidth: baseWidth*2,
                                    lineJoin: .round
                                ))
                        .onAppear(){
                            oscobj.start()
                        }
                        .onDisappear(){
                            oscobj.stop()
                        }

                    TimelineView(.animation) { context in
                        let time = context.date.timeIntervalSinceReferenceDate
                        let divider: TimeInterval = 20;
                        let remainder = time.truncatingRemainder(dividingBy: divider)
                        //                    Text("\(moduloTime)")
                        let offset = geometry.size.width*((remainder-divider/2)/divider);
                        Rectangle()
                            .foregroundColor(/*@START_MENU_TOKEN@*/Color.blue/*@END_MENU_TOKEN@*/)
                            .offset(x: offset)
                            .frame(width: baseWidth*5)
                            .opacity(0.5)
                    }
                }
            }
            HStack{
                VStack{
                    Button("Up") {
                        oscobj.rampUp()
                    }
                    Button("Down") {
                        oscobj.rampDown()
                    }
                }
                VStack{
                    Button("On") {
                        oscobj.on()
                    }
                    Button("Off") {
                        oscobj.off()
                    }

                }

            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
