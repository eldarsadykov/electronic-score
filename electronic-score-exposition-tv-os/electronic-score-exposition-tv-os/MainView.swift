//
//  MainView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 11.07.2022.
//

import SwiftUI

func triangleCoordY(y: Double, y1: Double, y2: Double, y3: Double) -> Double {
    (y - min(y1, y2, y3)) / (max(y1, y2, y3) - min(y1, y2, y3))
}

func triangleOffset(dim: Double, dimMin: Double, dimMax: Double) -> Double {
    let step1 = -dim / 2 // move center of the object to the left side of canvas
    let step2 = step1 + (dimMax - dimMin) * dim / 2 // offset by a half of width of the object to put its left side to the left side of canvas
    let step3 = step2 + dimMin * dim // do normal offset based on coordinates
    return step3
}

struct MainView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // BACKGROUND
                Grid()
                    .stroke(lineWidth: 2)
                    .opacity(0.25)
                // CONTENT
                TriangleFramed(x: (triangleScoreTest[1] - triangleScoreTest[0]) / (triangleScoreTest[2] - triangleScoreTest[0]), y1: triangleCoordY(y: triangleScoreTest[3], y1: triangleScoreTest[3], y2: triangleScoreTest[4], y3: triangleScoreTest[5]), y2: triangleCoordY(y: triangleScoreTest[4], y1: triangleScoreTest[3], y2: triangleScoreTest[4], y3: triangleScoreTest[5]), y3: triangleCoordY(y: triangleScoreTest[5], y1: triangleScoreTest[3], y2: triangleScoreTest[4], y3: triangleScoreTest[5]))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .frame(width: (triangleScoreTest[2] - triangleScoreTest[0]) * geo.size.width, height: (max(triangleScoreTest[3], triangleScoreTest[4], triangleScoreTest[5]) - min(triangleScoreTest[3], triangleScoreTest[4], triangleScoreTest[5])) * geo.size.height)
                    .offset(x: triangleOffset(dim: geo.size.width, dimMin: triangleScoreTest[0], dimMax: triangleScoreTest[2]), y: -triangleOffset(dim: geo.size.height, dimMin: min(triangleScoreTest[3], triangleScoreTest[4], triangleScoreTest[5]), dimMax: max(triangleScoreTest[3], triangleScoreTest[4], triangleScoreTest[5])))

                // FOREGROUND
                Playhead()
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .butt))
                    .foregroundColor(Color.red)
                    .opacity(0.5)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
