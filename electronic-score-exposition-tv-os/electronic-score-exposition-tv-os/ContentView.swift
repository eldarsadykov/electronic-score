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
        osc.$amplitude.ramp(to: 0.5, duration: 2)
    }
    func off(){
        osc.$amplitude.ramp(to: 0, duration: 2)
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
            ZStack{                Rectangle()
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)

                Triangle()
                    .onAppear(){
                        oscobj.start()
                    }
                    .onDisappear(){
                        oscobj.stop()
                    }
                    .border(Color.white, width: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/)
                    .padding(.all, 200.0)

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
