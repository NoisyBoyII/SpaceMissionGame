//
//  Bullet.swift
//  Snake
//
//  Created by Pratap Singh on 17/10/19.
//  Copyright © 2019 Pratap Singh. All rights reserved.
//

import SpriteKit

class Bullet: SKShapeNode {
    
    func setSpecifics(x: CGFloat, y: CGFloat) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.fillColor = UIColor.red
        self.physicsBody?.categoryBitMask = PhysicsCategories.bulletCategory
        self.physicsBody?.contactTestBitMask = PhysicsCategories.enemyCategory
        self.physicsBody?.isDynamic = true
        self.position = CGPoint(x: x, y: y)
    }
}
