//
//  ShapeFocusTestView.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 07.07.2022.
//

import SwiftUI

struct ShapeFocusTestView: View {
//    @FocusState private var focusedTriangle: Int?

//    for i in 0 ..< 4 {
//        print("hi")
    ////        focusArray.append(false)
//    }

    struct TriangleFramed: InsettableShape {
        let x: Double, y1: Double, y2: Double, y3: Double
        var insetAmount = 0.0
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let minX = rect.minX + insetAmount
            let minY = rect.minY + insetAmount
            let maxX = rect.maxX - insetAmount * 2
            let maxY = rect.maxY - insetAmount * 2
            let dX = maxX - minX
            let dY = maxY - minY
            path.move(to: CGPoint(x: minX, y: maxY - y1 * dY))
            path.addLine(to: CGPoint(x: minX + x * dX, y: maxY - y2 * dY))
            path.addLine(to: CGPoint(x: maxX, y: maxY - y3 * dY))
            path.closeSubpath()
            return path
        }

        func inset(by amount: CGFloat) -> some InsettableShape {
            var tri = self
            tri.insetAmount += amount
            return tri
        }
    }

    @FocusState private var t1focus: Bool
    @FocusState private var t2focus: Bool
    @FocusState private var t3focus: Bool
    @FocusState private var t4focus: Bool

    @State private var page = false
    var body: some View {
        VStack {
            ZStack {
                TriangleFramed(x: 0.1, y1: 0, y2: 1, y3: 0.5)
                    .stroke(style: StrokeStyle(lineWidth: 2 * (2 + (t1focus ? 1 : 0)), lineCap: .round, lineJoin: .round))
                    .background(TriangleFramed(x: 0.1, y1: 0, y2: 1, y3: 0.5).foregroundColor(Color(hue: 0, saturation: 1, brightness: 1, opacity: 1)))

                    .focusable()
                    .focused($t1focus)
                    .frame(width: 300, height: 500)
//                    .background(Color.white)
                    .offset(x: -100)
//                    .opacity(0.25)

                TriangleFramed(x: 0.8, y1: 0.5, y2: 1, y3: 0)
                    .stroke(style: StrokeStyle(lineWidth: 2 * (2 + (t2focus ? 1 : 0)), lineCap: .round, lineJoin: .round))
                    .focusable()
                    .focused($t2focus)
                    .frame(width: 300, height: 700)
//                    .background(Color.white)
                    .offset(x: 0, y: 300)
//                    .opacity(0.25)
                TriangleFramed(x: 0.5, y1: 0, y2: 1, y3: 0)
                    .stroke(style: StrokeStyle(lineWidth: 2 * (2 + (t3focus ? 1 : 0)), lineCap: .round, lineJoin: .round))
                    .focusable()
                    .focused($t3focus)
                    .frame(width: 300, height: 200)
//                    .background(Color.white)
//                    .opacity(0.25)
                    .offset(x: 300)
                TriangleFramed(x: 0.5, y1: 0, y2: 1, y3: 0.5)
                    .stroke(style: StrokeStyle(lineWidth: 2 * (2 + (t4focus ? 1 : 0)), lineCap: .round, lineJoin: .round))
                    .focusable()
                    .focused($t4focus)
                    .frame(width: 300, height: 200)
//                    .background(Color.white)
//                    .opacity(0.25)
                    .offset(x: 700)
                Button("Toggle Page") {
                    withAnimation {
                        page.toggle()
                    }
                }
            }
            .offset(x: 300+(page ? 1.0 : 0.0) * -1060)
        }
    }
}

struct ShapeFocusTestView_Previews: PreviewProvider {
    static var previews: some View {
        ShapeFocusTestView()
    }
}
