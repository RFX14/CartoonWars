//
//  GameViewController.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/13/26.
//

import UIKit
internal import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            let scene = GameScene(size: .init(width: 960, height: 540))
//            
//            // Set the scale mode to scale to fit the window
//            scene.scaleMode = .aspectFill
//            view.preferredFramesPerSecond = 120
//            
//            // Present the scene
//            view.presentScene(scene)
//            
//            view.ignoresSiblingOrder = true
//            
//            view.showsFPS = true
//            view.showsNodeCount = true
//            view.showsPhysics = true
//        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
