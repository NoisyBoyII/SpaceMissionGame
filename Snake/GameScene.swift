//
//  GameScene.swift
//  Snake
//
//  Created by Pratap Singh on 14/10/19.
//  Copyright © 2019 Pratap Singh. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let planeCategory: UInt32 = 0x1
    static let enemyCategory: UInt32 = 0x1 << 1
    static let bulletCategory: UInt32 = 0x1 << 1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var starfield:SKEmitterNode!
    private var scoreLabel : SKLabelNode?
    private var score: Int = 0 {
        didSet {
            scoreLabel!.text = "Score: \(score)"
        }
    }
    private var player = SKSpriteNode(imageNamed: "plane")
    private var isGameOver: Bool = false
    
    override func didMove(to view: SKView) {
        
        addGravity()
        addBackGround()
        createPlayer()
        addScoreLabel()
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster),SKAction.wait(forDuration: 2.0)]) ))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addBullet), SKAction.wait(forDuration: 1.0)])))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            let speed = CGFloat(1000)
            let duration = distance(from: player.position,to: touchLocation) / speed
            player.run(SKAction.sequence([SKAction.move(to:touchLocation, duration:TimeInterval(duration))]))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.tapCount == 2 {
            let angle = CGFloat(180 * 2)
            let flip  = CGFloat(360+angle).degreesToRadians
            let needleTurn = SKAction.sequence([
                SKAction.rotate(toAngle: -flip/2, duration: 0.2, shortestUnitArc:true),
                SKAction.rotate(toAngle: -flip, duration: 0.2, shortestUnitArc:false)
            ])
            player.run(needleTurn)
        }
    }
    
    func addScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel!.position = CGPoint(x: 100, y: self.frame.size.height - 60)
        scoreLabel!.fontSize = 36
        scoreLabel!.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel!)
    }
    
    func distance(from lhs: CGPoint, to rhs: CGPoint) -> CGFloat {
        return hypot(lhs.x.distance(to: rhs.x), lhs.y.distance(to: rhs.y))
    }

    
    func addGravity() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func addBackGround() {
        starfield = SKEmitterNode(fileNamed: "SparkParticle")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
              
        starfield.zPosition = -1
    }
    
    func createPlayer() {
        player.position = CGPoint(x: frame.midX, y: frame.minY + player.size.height)
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.categoryBitMask = PhysicsCategories.planeCategory
        player.physicsBody?.isDynamic = false
        addChild(player)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float.random(in: Float(min) ... Float(max)))
    }

    func addMonster() {
      
      let monster = SKSpriteNode(imageNamed: "enemy")
      monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
      monster.physicsBody?.categoryBitMask = PhysicsCategories.enemyCategory
      monster.physicsBody?.contactTestBitMask = PhysicsCategories.planeCategory
        
      monster.physicsBody?.isDynamic = true
      
      let actualX = random(min: frame.minX , max:  frame.maxX)
      
      monster.position = CGPoint(x: actualX , y: size.height - monster.size.height/2)
      
      addChild(monster)
      
      let actionMove = SKAction.move(to: CGPoint(x:actualX , y: monster.size.width/2),
                                     duration: TimeInterval(3))
      let actionMoveDone = SKAction.removeFromParent()
      monster.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addBullet() {
        let ammo = SKShapeNode(circleOfRadius: 5)
        ammo.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        ammo.fillColor = UIColor.red
        ammo.physicsBody?.categoryBitMask = PhysicsCategories.bulletCategory
        ammo.physicsBody?.contactTestBitMask = PhysicsCategories.enemyCategory
        ammo.physicsBody?.isDynamic = true
        ammo.position = player.position
        ammo.position.y += 5
        addChild(ammo)
        
        let actionMove = SKAction.move(to: CGPoint(x:player.position.x , y: frame.height + 5),
                                       duration: TimeInterval(1))
        let actionMoveDone = SKAction.removeFromParent()
        ammo.run(SKAction.sequence([actionMove, actionMoveDone]))
    }

    
}


extension GameScene {
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        let contactMask = firstBody.categoryBitMask | secondBody.categoryBitMask
        if contactMask == PhysicsCategories.enemyCategory | PhysicsCategories.planeCategory {
            planeDidCollideWithEnemy(planeNode: firstBody.node as! SKSpriteNode, enemyNode: secondBody.node as! SKSpriteNode)
        }
        if (firstBody.categoryBitMask & PhysicsCategories.bulletCategory) != 0 && (secondBody.categoryBitMask & PhysicsCategories.enemyCategory) != 0 {
           bulletDidCollideWithEnemy(bulletNode: firstBody.node as! SKShapeNode, enemyNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    func bulletDidCollideWithEnemy(bulletNode:SKShapeNode, enemyNode:SKSpriteNode) {
    
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = enemyNode.position
        self.addChild(explosion)
        score += 1
        bulletNode.removeFromParent()
        enemyNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
    }
    
    func planeDidCollideWithEnemy(planeNode: SKSpriteNode, enemyNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
          explosion.position = planeNode.position
          self.addChild(explosion)
          
          planeNode.removeFromParent()
          enemyNode.removeFromParent()
         self.removeAllActions()
        let controller = UIAlertController(title: "Game Over", message: "You crashed your ship captain.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Restart", style: .destructive) { (action) in
            let nextScene = GameScene(size: self.scene!.size)
            nextScene.scaleMode = self.scaleMode
            nextScene.backgroundColor = UIColor.black
            self.view?.presentScene(nextScene, transition: SKTransition.fade(with: UIColor.black, duration: 1.5))
        }
        controller.addAction(action)
        self.view?.window?.rootViewController?.present(controller,animated: true)
          self.run(SKAction.wait(forDuration: 2)) {
              explosion.removeFromParent()
          }
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / .pi }
}
