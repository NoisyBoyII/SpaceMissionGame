//
//  Utils.swift
//  Snake
//
//  Created by Pratap Singh on 17/10/19.
//  Copyright © 2019 Pratap Singh. All rights reserved.
//
import UIKit

extension CGFloat {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / .pi }
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(Float.random(in: Float(min) ... Float(max)))
}

func distance(from lhs: CGPoint, to rhs: CGPoint) -> CGFloat {
    return hypot(lhs.x.distance(to: rhs.x), lhs.y.distance(to: rhs.y))
}

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let planeCategory: UInt32 = 0x1
    static let enemyCategory: UInt32 = 0x1 << 1
    static let bulletCategory: UInt32 = 0x2 << 1
    static let PowerUPCategory: UInt32 = 0x4 << 1
}
