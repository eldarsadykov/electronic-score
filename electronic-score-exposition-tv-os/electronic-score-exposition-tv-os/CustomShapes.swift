//
//  CustomShapes.swift
//  electronic-score-exposition-tv-os
//
//  Created by Эльдар Садыков on 11.07.2022.
//

import SwiftUI

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

struct Playhead: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

struct Triangle: InsettableShape {
    let x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double
    var insetAmount = 0.0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let minX = rect.minX + insetAmount
        //        let minY = rect.minY + insetAmount
        let maxX = rect.maxX - insetAmount * 2
        let maxY = rect.maxY - insetAmount * 2
        path.move(to: CGPoint(x: minX + x1 * maxX, y: maxY - y1 * maxY))
        path.addLine(to: CGPoint(x: minX + x2 * maxX, y: maxY - y2 * maxY))
        path.addLine(to: CGPoint(x: minX + x3 * maxX, y: maxY - y3 * maxY))
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var tri = self
        tri.insetAmount += amount
        return tri
    }
}

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
