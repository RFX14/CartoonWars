//
//  GameScene.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/13/26.
//

import SpriteKit
import GameplayKit

@Observable
class GameScene: SKScene {
    private var createButton: SKShapeNode!
    
    private let cam = SKCameraNode()
    private var prevTime: TimeInterval = .zero
    private var cleanUp: TimeInterval = .zero
    private var attacks: [AttackPair] = []
    let tower: Tower
    let enemyTower: Tower = Tower(isEnemy: true)
    
    init(size: CGSize, playerTower: Tower) {
        self.tower = playerTower
        super.init(size: size)
        
        scene?.scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.camera = cam
        addChild(cam)
        setupCameraConstraints()
        
        attacks.reserveCapacity(500)
        
        createSky()
        createClouds()
        addChild(tower)
        addChild(enemyTower)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func setupCameraConstraints() {
        guard let camera = self.camera else { return }

        let uiHeight: CGFloat = 45
        
        // 1. Your desired absolute map boundaries
        let mapLeftEdge: CGFloat = -250
        let mapRightEdge: CGFloat = 3250
        
        // 2. Calculate half of your scene's width
        let halfScreenWidth = self.size.width / 2
        
        // 3. Calculate the true limits for the camera's CENTER point
        let lowerX = mapLeftEdge + halfScreenWidth
        let upperX = mapRightEdge - halfScreenWidth
        
        // 4. Create the X range using those new center limits
        let xRange = SKRange(lowerLimit: lowerX, upperLimit: upperX)
        
        // 5. Keep your Y-axis locked to the floor (as discussed previously)
        let groundYPosition: CGFloat = -50
        let cameraYLock = groundYPosition + (self.size.height / 2) - uiHeight
        let yRange = SKRange(constantValue: cameraYLock)
        
        // 6. Apply both constraints
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        camera.constraints = [constraint]
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
        if currentTime - prevTime >= 0.25 {
            enemyTower.place(troop: Troop<Orc>.orc)
            if tower.enableArrow {
                tower.shootArrow()
            }
            prevTime = currentTime
        }
        
        // Clean up unused attacks to prevent array resizing
        if attacks.count > 490 && currentTime - cleanUp >= 10 {
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
            if nodeA.reciever.stats.health <= 0 {
                attacks[idx].isActive = false
                nodeB.reciever.walk()
            } else if nodeB.reciever.stats.health <= 0 {
                attacks[idx].isActive = false
                nodeA.reciever.walk()
            }
        }
    }
    
    // Performs attack
    func attack(_ attack: inout Attack, currentTime: TimeInterval) {
        if attack.reciever.state != .attack {
            attack.reciever.attack()
        }
        
        
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
}

// MARK: Helper Creators
extension GameScene {
    func createClouds() {
        for i in 1...6 {
            let cloud = SKSpriteNode(imageNamed: "cloud")
            cloud.zPosition = .greatestFiniteMagnitude
            cloud.anchorPoint = .init(x: 0.5, y: 0)
            let width = cloud.size.width * 0.5
            let xPos: CGFloat = (size.width / 2) + CGFloat(i) * width - size.width - 200
            let yPos: CGFloat = 400
            cloud.position = .init(x: xPos, y: yPos)
            cloud.setScale(0.2)
            addChild(cloud)
        }
    }
    
    func createSky() {
        let sky = SKSpriteNode(imageNamed: "sky")
        sky.zPosition = .leastNormalMagnitude
        sky.setScale(0.3)
        cam.addChild(sky)
    }
}

// MARK: Physics Stuff
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        let collision = contactA | contactB
        let playerEnemyContact = PhysicsCategory.Player.rawValue | PhysicsCategory.Enemy.rawValue
        
        if collision == playerEnemyContact {
            // Stop the action immediately
            let nodeA = contact.bodyA.node as? BaseTroop
            let nodeB = contact.bodyB.node as? BaseTroop
            
            let attackA2B: Attack = Attack(
                reciever: nodeB!,
                dmgs: nodeA!.stats.attackDmg,
                frequency: nodeA!.isEnemy ? 1 : 0.4,
            )
            
            let attackB2A: Attack = Attack(
                reciever: nodeA!,
                dmgs: nodeB!.stats.attackDmg,
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
        } else if contactA == PhysicsCategory.Arrow.rawValue {
            guard let nodeA = contact.bodyA.node as? Arrow else { return }
            guard let nodeB = contact.bodyB.node as? BaseTroop else { return }
            
            nodeB.takeDamage(dmg: nodeA.attackDmg.first!)
            
            nodeA.removeFromParent()
        } else if contactB == PhysicsCategory.Arrow.rawValue {
            guard let nodeB = contact.bodyB.node as? Arrow else { return }
            guard let nodeA = contact.bodyA.node as? BaseTroop else { return }
            
            nodeA.takeDamage(dmg: nodeB.attackDmg.first!)
            nodeB.removeFromParent()
        }
    }
}
