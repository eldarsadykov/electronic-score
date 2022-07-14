//
//  MainView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 11.07.2022.
//

import SwiftUI

struct MainView: View {
    let timer = Timer.publish(every: 1 / 144, on: .main, in: .common).autoconnect()
    @State private var counter = 0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // BACKGROUND
                Grid()
                    .stroke(lineWidth: 2)
                    .opacity(0.25)
                // CONTENT
                ForEach(0 ..< score.count, id: \.self) { i in
                    let incircle = incircleParams(score[i], width: geo.size.width, height: geo.size.height)
                    TriangleFramed(x: (score[i][1] - score[i][0]) / (score[i][2] - score[i][0]), y1: triangleCoordY(y: score[i][3], y1: score[i][3], y2: score[i][4], y3: score[i][5]), y2: triangleCoordY(y: score[i][4], y1: score[i][3], y2: score[i][4], y3: score[i][5]), y3: triangleCoordY(y: score[i][5], y1: score[i][3], y2: score[i][4], y3: score[i][5]))
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .frame(width: (score[i][2] - score[i][0]) * geo.size.width, height: (max(score[i][3], score[i][4], score[i][5]) - min(score[i][3], score[i][4], score[i][5])) * geo.size.height)
                        .offset(x: triangleOffset(dim: geo.size.width, dimMin: score[i][0], dimMax: score[i][2]), y: -triangleOffset(dim: geo.size.height, dimMin: min(score[i][3], score[i][4], score[i][5]), dimMax: max(score[i][3], score[i][4], score[i][5])))

                    Ellipse()
                        .opacity(0.25)
                        .frame(width: incircle[2], height: incircle[2])
                        .offset(x: incircle[0], y: -incircle[1])
                }

                // FOREGROUND
                Playhead()
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .butt))
                    .foregroundColor(Color.green)
                    .opacity(0.5)
                    .onReceive(timer) { _ in
                        self.counter += 1
                        self.counter %= 5000
                    }
                    .offset(x: cursorOffsetCalc(counter, width: geo.size.width, max: 5000))
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
