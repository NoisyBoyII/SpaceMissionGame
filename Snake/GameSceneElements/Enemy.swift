//
//  Enemy.swift
//  Snake
//
//  Created by Pratap Singh on 17/10/19.
//  Copyright © 2019 Pratap Singh. All rights reserved.
//

import SpriteKit

class Enemy: SKSpriteNode {
    func setSpecifics(minX: CGFloat, maxX: CGFloat, height: CGFloat) {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategories.enemyCategory
        self.physicsBody?.contactTestBitMask = PhysicsCategories.planeCategory
        self.physicsBody?.isDynamic = true
        let actualX = random(min: minX , max:  maxX - self.size.width)
        self.position = CGPoint(x: actualX , y: height - self.size.height/2)
    }
}
