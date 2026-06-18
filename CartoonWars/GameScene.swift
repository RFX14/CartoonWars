//
//  GameScene.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/13/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var createButton: SKShapeNode!
    private var bkMenubar: SKShapeNode!
    private var buttonCount: Int = .zero
    private let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .yellow,
        .orange,
        .purple,
        .cyan,
        .gray,
        .magenta,
        .black
    ]
    
    private let cam = SKCameraNode()
    private var prevTime: TimeInterval = .zero
    private var cleanUp: TimeInterval = .zero
    
    private var attacks: [AttackPair] = []
    
    override func didMove(to view: SKView) {
        self.camera = cam
        addChild(cam)
        attacks.reserveCapacity(200)
        
        createSky()
        createHUD()
        createClouds()
        
        self.physicsWorld.contactDelegate = self
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Create new enemy every X secs
        if currentTime - prevTime >= 0.5 {
            createEnemy()
            prevTime = currentTime
        }
        
        // Clean up unused attacks to prevent array resizing
        if attacks.count > 100 && currentTime - cleanUp >= 10 {
            attacks.removeAll(where: { !$0.isActive })
            print("Capacity: \(attacks.capacity)")
            cleanUp = currentTime
        }
        
        for (idx, pair) in attacks.enumerated() where pair.isActive {
            // Perform Attacks
            attack(&attacks[idx].nodeA, currentTime: currentTime)
            attack(&attacks[idx].nodeB, currentTime: currentTime)
            
            // Ensure at least one of the nodes is alive to keep attacking
            let nodeA = attacks[idx].nodeA
            let nodeB = attacks[idx].nodeB
            if nodeA.reciever.health <= 0 {
                attacks[idx].isActive = false
                nodeB.reciever.walk(duration: 20)
            }
            
            if nodeB.reciever.health <= 0 {
                attacks[idx].isActive = false
                nodeA.reciever.walk(duration: 20)
            }
        }
    }
    
    // Performs attack
    func attack(_ attack: inout Attack, currentTime: TimeInterval) {
        if currentTime - attack.prevHit >= attack.frequency {
            let dmg = attack.dmgs.randomElement()!
            attack.reciever.takeDamage(dmg: dmg)
            attack.prevHit = currentTime
        }
    }
}

// MARK: Touch Response
extension GameScene {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let camera = self.camera else { return }
        
        // Get the current and previous touch locations in the scene
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        // Calculate the difference between touches (the drag distance)
        let translationX = location.x - previousLocation.x
        
        // Update the camera's position (invert the translation to move camera in direction of drag)
        camera.position.x -= translationX
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Get touch in camera space, then convert down to menubar's local space
        let touchInCam = touch.location(in: cam)
        let touchInMenubar = CGPoint(
            x: touchInCam.x - bkMenubar.position.x,
            y: touchInCam.y - bkMenubar.position.y
        )
        
        for (idx, color) in colors.enumerated() {
            let name = "create_troop\(idx)"
            if let button = bkMenubar.childNode(withName: name),
               button.frame.contains(touchInMenubar) {
                createTroop(color: color, mass: CGFloat(idx))
                return
            }
        }
    }
}

// MARK: Helper Creators
extension GameScene {
    func createClouds() {
        for i in 1...6 {
            let cloud = SKSpriteNode(imageNamed: "cloud")
            cloud.zPosition = .greatestFiniteMagnitude
            let width = cloud.size.width * 1.3
            let xPos: CGFloat = (size.width / 2) + CGFloat(i) * width - size.width - 200
            let yPos: CGFloat = (size.height / 2)
            cloud.position = .init(x: xPos, y: yPos)
            cloud.setScale(0.5)
            addChild(cloud)
        }
    }
    
    func createSky() {
        let sky = SKSpriteNode(imageNamed: "sky")
        sky.zPosition = .leastNormalMagnitude
        sky.setScale(0.3)
        cam.addChild(sky)
    }
    
    func createEnemy() {
        let w = (size.width + size.height) * 0.05
        let n = Troop(size: .init(width: w, height: w), mass: 5, isEnemy: true)
        let xPos = size.width + w + 2500
        let yPos = -(size.height / 2) + (w/2) + w
        n.zPosition = 1
        
        n.position = .init(x: xPos, y: yPos)
        n.walk(duration: 15)
        addChild(n)
    }
    
    func createTroop(color: UIColor = .white, mass: CGFloat) {
        let w = (size.width + size.height) * 0.05
        let n = Troop(size: .init(width: w, height: w), color: color, mass: mass)
        n.health += Float(mass)
        let xPos = -(size.width / 2) + w
        let yPos = -(size.height / 2) + (w/2) + w
        n.zPosition = 1
        
        n.position = .init(x: xPos, y: yPos)
        n.walk(duration: 15 + mass)
        addChild(n)
    }
    
    private func createHUD() {
        let w = (size.width + size.height) * 0.05
        let yPos = -(size.height / 2) + (w/2)
        
        // Menu Bar
        bkMenubar = SKShapeNode(rectOf: CGSize(width: size.width, height: w + 2), cornerRadius: w * 0.3)
        bkMenubar.position = .init(x: 0, y: yPos)
        bkMenubar.zPosition = .greatestFiniteMagnitude
        bkMenubar.lineWidth = 2.5
        bkMenubar.fillColor = .brown
        bkMenubar.strokeColor = .white
        cam.addChild(bkMenubar)
            
        createButton = SKShapeNode(rectOf: CGSize(width: w - 1, height: w - 1), cornerRadius: w * 0.3)

        for (idx, color) in colors.enumerated() {
            createButton(for: "create_troop\(idx)", color: color)
        }
    }
    
    func createButton(for name: String, color: UIColor) {
        guard let n = createButton.copy() as? SKShapeNode else { return }
        let additionPos: CGFloat = n.frame.width * CGFloat(buttonCount + 1)
        let xPos = -(bkMenubar.frame.width / 2) + additionPos
        let yPos = -(bkMenubar.frame.height / 2) + (n.frame.width / 2)
        buttonCount += 1 //update count
        
        n.fillColor = color
        n.strokeColor = color
        n.position = .init(x: xPos, y: yPos)
        n.name = name
        bkMenubar.addChild(n)
    }
}

// MARK: Physics Stuff
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Check if the player collided with the obstacle
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        let requiredMask = PhysicsCategory.Player.rawValue | PhysicsCategory.Enemy.rawValue
        
        if collision == requiredMask {
            // Stop the action immediately
            let nodeA = contact.bodyA.node as? Troop
            let nodeB = contact.bodyB.node as? Troop
            
            let attackA2B: Attack = Attack(
                reciever: nodeB!,
                dmgs: nodeA!.dmgs,
                frequency: nodeA!.isEnemy ? 1 : 0.4,
            )
            
            let attackB2A: Attack = Attack(
                reciever: nodeA!,
                dmgs: nodeB!.dmgs,
                frequency: nodeB!.isEnemy ? 1 : 0.4,
            )
            
            let pair: AttackPair = .init(
                nodeA: attackA2B,
                nodeB: attackB2A,
                isActive: true
            )
            
            attacks.append(pair)
            
            // Attacking animation
            nodeA?.attack()
            nodeB?.attack()
            // Handle your collision logic (e.g., bounce, explosion, game over)
        }
    }
}
