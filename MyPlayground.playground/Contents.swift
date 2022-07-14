import SwiftUI

func triangleCoordY(y: Double, y1: Double, y2: Double, y3: Double) -> Double {
    (y - min(y1, y2, y3)) / (max(y1, y2, y3) - min(y1, y2, y3))
}

func triangleOffset(dim: Double, dimMin: Double, dimMax: Double) -> Double {
    let step1 = -dim / 2 // move center of the object to the left/top side of canvas
    let step2 = step1 + (dimMax - dimMin) * dim / 2 // offset by a half of width/height of the object to put its left/top side to the left/top side of the canvas
    let step3 = step2 + dimMin * dim // do normal offset based on coordinates
    return step3
}

func incircleParams(_ triangleParams: [Double]) -> [Double] {
    let x1: Double = triangleParams[0]
    let x2: Double = triangleParams[1]
    let x3: Double = triangleParams[2]
    let y1: Double = triangleParams[3]
    let y2: Double = triangleParams[4]
    let y3: Double = triangleParams[5]
    let a: Double = distance(x2, y2, x3, y3)
    let b: Double = distance(x1, y1, x3, y3)
    let c: Double = distance(x1, y1, x2, y2)
    let s = (a + b + c) / 2
    let icX = (a * x1 + b * x2 + c * x3) / (a + b + c)
    let icY = (a * y1 + b * y2 + c * y3) / (a + b + c)
    let icR = sqrt(((s - a) * (s - b) * (s - c)) / s)
    return [icX, icY, icR]
}

func distance(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Double {
    return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
}

func cursorOffsetCalc(_ count: Int, width: CGFloat, max: Int) -> CGFloat {
    width * CGFloat(count) / CGFloat(max)
}

incircleParams([0, 0.5, 1, 0, 1, 0])
