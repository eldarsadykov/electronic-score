//
//  MainView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 11.07.2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // BACKGROUND
                Grid()
                    .stroke(lineWidth: 2)
                    .opacity(0.25)
                // CONTENT
                TriangleFramed(x: triangleScoreTest[1], y1: triangleScoreTest[3], y2: triangleScoreTest[4], y3: triangleScoreTest[5])
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
//                    .frame(width: (triangleScoreTest[2] - triangleScoreTest[0]) * geo.size.width, height: 100)
                    .frame(width: (triangleScoreTest[2] - triangleScoreTest[0]) * geo.size.width, height: (max(triangleScoreTest[3], triangleScoreTest[4], triangleScoreTest[5]) - min(triangleScoreTest[3], triangleScoreTest[4], triangleScoreTest[5])) * geo.size.height)
//                    .offset(x: 0, y: 0)
//                    .offset(x: triangleScoreTest[0] * geo.size.width, y: 0)

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
