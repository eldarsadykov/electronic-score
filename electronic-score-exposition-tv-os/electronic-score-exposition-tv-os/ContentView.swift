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

    var osc = Oscillator()

    init() {
        engine.output = osc

    }
    func start(){
        osc.frequency = 440;
        osc.amplitude = 1.0;

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
}

struct ContentView: View {
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: (rect.minX+0.5*rect.maxX), y: rect.minY))
            
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            //path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
            //control: CGPoint(x: rect.midX, y: rect.midY))
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            //path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY),
            //control: CGPoint(x: rect.maxX, y: rect.midY))
            
            path.closeSubpath()
            return path
        }
    }
    
    var oscobj = OscillatorObject()
    
    var body: some View {
        VStack{
            Triangle()
                .stroke(lineWidth: 3)
                .padding()
                .onAppear(){
                    oscobj.start()
                }
                .onDisappear(){
                    oscobj.stop()
                }
            //.rotationEffect(Angle(degrees: 270))
            .frame(width: 300, height: 200)
            
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
