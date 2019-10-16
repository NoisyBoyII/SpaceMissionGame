//
//  GameViewController.swift
//  Snake
//
//  Created by Pratap Singh on 14/10/19.
//  Copyright © 2019 Pratap Singh. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGameScene()
        NotificationCenter.default.addObserver(self, selector: #selector(ShowAlert), name: Notification.Name(rawValue: "NewGame"), object: nil)
    }
    
    func createGameScene() {
        if let view = self.view as! SKView? {
            
            let scene = GameScene(size: view.bounds.size)
                
            scene.scaleMode = .aspectFill
            scene.backgroundColor = .black

            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    @objc func ShowAlert() {
        let controller = UIAlertController(title: "Game Over", message: "You crashed your ship captain.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Restart", style: .destructive) { (action) in
            self.createGameScene()
        }
        let endAction = UIAlertAction(title: "End Game", style: .cancel) { (action) in
            self.backToParentController()
        }
        controller.addAction(action)
        controller.addAction(endAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func backToParentController() {
        self.dismiss(animated: true, completion: nil)
    }
}
