//
//  Plane.swift
//  Snake
//
//  Created by Pratap Singh on 17/10/19.
//  Copyright © 2019 Pratap Singh. All rights reserved.
//

import SpriteKit

class Plane: SKSpriteNode {
    
    convenience init(imageName: String) {
        self.init(imageNamed:imageName)
    }
     
    func setSpecifics(x: CGFloat, y: CGFloat) {
        self.position = CGPoint(x: x, y: y + self.size.height)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.categoryBitMask = PhysicsCategories.planeCategory
        self.physicsBody?.isDynamic = false
    }
    
}
