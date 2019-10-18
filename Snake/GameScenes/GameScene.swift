//
//  GameScene.swift
//  Snake
//
//  Created by Pratap Singh on 14/10/19.
//  Copyright © 2019 Pratap Singh. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var starfield:SKEmitterNode!
    private var scoreLabel : SKLabelNode?
    private var score: Int = 0 {
        didSet {
            scoreLabel!.text = "Score: \(score)"
        }
    }
    private var player: Plane?
    private lazy var enemyTexture = SKTexture(imageNamed: enemyName)
    private var isGameOver: Bool = false
    private var isAddedPower: Bool = false
    
    override func didMove(to view: SKView) {
        
        addGravity()
        addBackGround()
        createPlayer()
        addScoreLabel()
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster),SKAction.wait(forDuration: 2.0)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addBullet), SKAction.wait(forDuration: 1.0)])), withKey: "singleBullet")
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPowerUp), SKAction.wait(forDuration: 60.0)])), withKey: "powerUP")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            let speed = CGFloat(1000)
            let duration = distance(from: player!.position,to: touchLocation) / speed
            player!.run(SKAction.sequence([SKAction.move(to:touchLocation, duration:TimeInterval(duration))]))
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
            player!.run(needleTurn)
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
    
    func addGravity() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func addBackGround() {
        starfield = SKEmitterNode(fileNamed: backGroundName)
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
              
        starfield.zPosition = -1
    }
    
    func createPlayer() {
        player = Plane(imageName: playerName)
        player!.setSpecifics(x: frame.midX, y: frame.minY)
        addChild(player!)
    }

    func addMonster() {
        let enemy = Enemy(texture: enemyTexture)
        enemy.setSpecifics(minX: frame.minX, maxX: frame.maxX, height: size.height)
        addChild(enemy)
        let actionMove = SKAction.move(to: CGPoint(x:enemy.position.x, y: enemy.size.width/2),duration: TimeInterval(3))
        let actionMoveDone = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addBullet() {
        guard let player = player else {
            return
        }
        let bullet = Bullet(circleOfRadius: 5)
        bullet.setSpecifics(x: player.position.x, y: player.position.y)
        addChild(bullet)
        
        let actionMove = SKAction.move(to: CGPoint(x:player.position.x , y: frame.height + 5),
                                       duration: TimeInterval(1))
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }

    func addPowerUp() {
        let power = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        power.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 5))
        power.fillColor = UIColor.systemIndigo
        power.physicsBody?.categoryBitMask = PhysicsCategories.PowerUPCategory
        power.physicsBody?.contactTestBitMask = PhysicsCategories.planeCategory
        power.physicsBody?.isDynamic = true
        
        let actualX = random(min: frame.minX , max:  frame.maxX)
        
        power.position = CGPoint(x: actualX, y: size.height - 5)
        addChild(power)
        
        let actionMove = SKAction.move(to: CGPoint(x:actualX , y: 3),
                                       duration: TimeInterval(3))

        let actionMoveDone = SKAction.removeFromParent()
        power.run(SKAction.sequence([actionMove, actionMoveDone]))
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
        
        if contactMask == PhysicsCategories.planeCategory | PhysicsCategories.PowerUPCategory {
            secondBody.node?.removeFromParent()
            if isAddedPower == false {
                self.removeAction(forKey: "singleBullet")
                self.removeAction(forKey: "powerUP")
                run(SKAction.repeatForever(SKAction.sequence([SKAction.run(powerUp), SKAction.wait(forDuration: 1.0)])), withKey: "doubleBullet")
                isAddedPower = true
            }
        }
        
        if contactMask == PhysicsCategories.bulletCategory | PhysicsCategories.enemyCategory {
            if let node = firstBody.node {
                bulletDidCollideWithEnemy(bulletNode: secondBody.node as! SKShapeNode, enemyNode: node as! SKSpriteNode)
            }
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
        showAlert()
        planeNode.removeFromParent()
        enemyNode.removeFromParent()
        self.removeAllActions()
        
        self.run(SKAction.wait(forDuration: 3)) {
            explosion.removeFromParent()
        }
    }
    
    func powerUp() {
        
        guard let player = player else {
            return
        }
        
        let bulletLeft = Bullet(circleOfRadius: 5)
        let bulletRight = Bullet(circleOfRadius: 5)
        
        bulletLeft.setSpecifics(x: player.position.x - 18, y: player.position.y + 5)
        addChild(bulletLeft)
        
        bulletRight.setSpecifics(x: player.position.x + 18, y: player.position.y + 5)
        addChild(bulletRight)

        let actionMoveLeft = SKAction.move(to: CGPoint(x:player.position.x - 18, y: frame.height + 5), duration: TimeInterval(1))
        let actionMoveRight = SKAction.move(to: CGPoint(x:player.position.x + 18 , y: frame.height + 5), duration: TimeInterval(1))
        let actionMoveDone = SKAction.removeFromParent()
        bulletLeft.run(SKAction.sequence([actionMoveLeft, actionMoveDone]))
        bulletRight.run(SKAction.sequence([actionMoveRight, actionMoveDone]))
    }
    
    func showAlert() {
        NotificationCenter.default.post(Notification(name: newGameName, object: nil, userInfo: nil))
    }
}
